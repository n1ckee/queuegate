//
//  TicketsController.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import UserNotifications

class ListTicketsController: UITableViewController, CLLocationManagerDelegate {
	
	private var ticketSnapshotListener: ListenerRegistration?
	private var queuesSnapshotListener: ListenerRegistration?
	private var tickets = [Ticket]()
	private var queues = [Queue]()
	private var organizations = [Organization]()
	private let cellId = "cellId"
	
	private let beaconUuid = "B0702880-A295-A8AB-F734-031A98A512DE"
	private let locationManager = CLLocationManager()
	private var region: CLBeaconRegion!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Your tickets"
		view.backgroundColor = .white
		
		tableView.register(ListTicketsCell.self, forCellReuseIdentifier: cellId)
		tableView.separatorStyle = .none
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus_not_black"), style: .plain, target: self, action: #selector(handleAddTicket))
		
		tickets = []
		queues = []
		organizations = []
		
		loadOrganizations()
		loadQueues()
		loadTickets()
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		refreshControl.tintColor = .white
		self.refreshControl = refreshControl
		
		initBeaconListener()
    }
	
	@objc private func handleRefresh() {
		print("Refresh")
		ticketSnapshotListener?.remove()
		queuesSnapshotListener?.remove()
		
		tickets = []
		queues = []
		organizations = []
		
		loadOrganizations()
		loadQueues()
		loadTickets()
		refreshControl?.endRefreshing()
	}
	
	private func loadTickets() {
		let db = Firestore.firestore()
		
		guard let userId = AuthenticationService.getUserUid() else {
			FirebaseCrashMessage("User id is undefined!")
			fatalError()
		}
		
		ticketSnapshotListener = db.collection("Tickets").whereField("user_id", isEqualTo: userId).addSnapshotListener({ (snapshot, error) in
			
			if let error = error {
				FirebaseCrashMessage("Failed to add listener: \(error)")
				fatalError()
			}
			
			guard let snapshot = snapshot else {
				FirebaseCrashMessage("Failed to set snapshot or it does not exist")
				fatalError()
			}
			
			snapshot.documentChanges.forEach({ (documentSnapshot) in
				
				if (documentSnapshot.type == .added) {
					let document = documentSnapshot.document
					if let ticket = Ticket(documentId: document.documentID, dictionary: document.data()) {
						self.tickets.append(ticket)
						self.tableView.reloadData()
					} else {
						FirebaseCrashMessage("Failed to create ticket object")
						fatalError()
					}
				} else if (documentSnapshot.type == .removed) {
					
					// todo: remove ticket from table view
				} else {
					
					let document = documentSnapshot.document
					if let ticketUpdate = Ticket(documentId: document.documentID, dictionary: document.data()) {
						let index = self.tickets.index(where: { (ticket) -> Bool in
							return ticket.id == document.documentID
						})
						
						if let index = index {
							self.tickets[index] = ticketUpdate
							self.tableView.reloadData()
						}
					}
				}
			})
		})
	}

	private func loadOrganizations() {
		let db = Firestore.firestore()
		
		db.collection("Organizations").getDocuments { (snapshot, error) in
			if let error = error {
				print("Failed to fetch user tickets: \(error.localizedDescription)")
				return
			}
			
			if let snapshot = snapshot {
				snapshot.documents.forEach({ (document) in
					if let organization = Organization(id: document.documentID, dictionary: document.data()) {
						self.organizations.append(organization)
					} else {
						print("Failed to create organization object")
					}
				})
				
				self.tableView.reloadData()
			}
		}
	}
	
	private func loadQueues() {
		let db = Firestore.firestore()
		db.collection("Queues").getDocuments { (snapshot, error) in
			if let error = error {
				print("Failed to fetch organization queues: \(error.localizedDescription)")
				return
			}
			
			if let snapshot = snapshot {
				snapshot.documents.forEach({ (document) in
					if let queue = Queue(documentId: document.documentID, dictionary: document.data()) {
						self.queues.append(queue)
					} else {
						print("Failed to create queue object")
					}
				})
				
				self.addQueueListener()
				self.tableView.reloadData()
			}
		}
	}
	
	private func addQueueListener() {
		let db = Firestore.firestore()
		queuesSnapshotListener = db.collection("Queues").addSnapshotListener({ (snapshot, error) in
			
			if let error = error {
				FirebaseCrashMessage("Failed to add listener: \(error)")
				fatalError()
			}
			
			guard let snapshot = snapshot else {
				FirebaseCrashMessage("Failed to set snapshot or it does not exist")
				fatalError()
			}
			
			snapshot.documentChanges.forEach({ (documentSnapshot) in
				
				if (documentSnapshot.type == .added) {
					
					// todo: listen for create event?
				} else if (documentSnapshot.type == .removed) {
					
					// todo: remove ticket from table view
				} else {
					let document = documentSnapshot.document
					if let queueUpdate = Queue(documentId: document.documentID, dictionary: document.data()) {
						let index = self.queues.index(where: { (queue) -> Bool in
							return queue.id == document.documentID
						})
						
						if let index = index {
							self.queues[index] = queueUpdate
							self.tableView.reloadData()
						}
					}
				}
			})
		})
	}
	
	@objc private func handleAddTicket() {
		let listOrganizationsController = ListOrganizationsController()
		self.navigationController?.pushViewController(listOrganizationsController, animated: true)
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = "No tickets taken..."
		label.textColor = .black
		label.textAlignment = .center
		label.font = UIFont.boldSystemFont(ofSize: 16)
		return label
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return tickets.count == 0 ? 250 : 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tickets.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListTicketsCell
		
		let ticket = tickets[indexPath.row]
		cell.ticket = ticket
		
		let queueIndex = self.queues.index(where: { (queue) -> Bool in
			return queue.id == ticket.queueId
		})
		
		if let queueIndex = queueIndex {
			cell.queue = queues[queueIndex]
		}
		
		let organizationIndex = self.organizations.index(where: { (organization) -> Bool in
			return organization.id == cell.queue?.organizationId
		})
		
		if let organizationIndex = organizationIndex {
			cell.organization = organizations[organizationIndex]
		}
		
		if ticket.userStatus == "checked" {
			cell.backgroundColorView.backgroundColor = UIColor.yellow
		} else {
			cell.backgroundColorView.backgroundColor = UIColor.white
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 200
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		ticketSnapshotListener?.remove()
		queuesSnapshotListener?.remove()
	}
	
	private func initBeaconListener() {
		region = CLBeaconRegion(proximityUUID: UUID(uuidString: beaconUuid)!, identifier: "TestBeacon")
		locationManager.delegate = self

		if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
			locationManager.requestWhenInUseAuthorization()
		}

		locationManager.startRangingBeacons(in: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

		DispatchQueue.global(qos: .background).async {
		if AuthenticationService.isAuthenticated() {
			let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }

			if knownBeacons.count < 1 {
				return
			}

			let closestBeacon = knownBeacons[0] as CLBeacon

			if closestBeacon.proximity == .immediate {
				print("Immediate")
				self.markQueuesAsChecked()
			} else if closestBeacon.proximity == .near {
				print("Near")
				self.markQueuesAsChecked()
			} else if closestBeacon.proximity == .far {
				print("Far")
			} else {
				print("Unknown")
			}
		}
		}
	}
	
	private func markQueuesAsChecked() {

		
		if let userId = AuthenticationService.getUserUid() {
			locationManager.stopRangingBeacons(in: region)
			
			DispatchQueue.global(qos: .background).async {
				let db = Firestore.firestore()

				db.collection("Tickets").whereField("user_id", isEqualTo: userId).whereField("user_status", isEqualTo: "idle").getDocuments(completion: { (snapshot, error) in
					if let error = error {
						print("Error: \(error)")
						return
					}

					guard let snapshot = snapshot else {
						FirebaseCrashMessage("Failed to get snapshot")
						fatalError()
					}

					snapshot.documents.forEach({ (document) in
						db.collection("Tickets").document(document.documentID).updateData(["user_status" : "checked"])
					})
					
					// self.sendUserNotification()
				})
			}
		}
	}
	
	private func sendUserNotification() {
		// todo: extract methods
		UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
			switch notificationSettings.authorizationStatus {
			case .notDetermined:
				self.requestAuthorization(completionHandler: { (success) in
					guard success else { return }
					
					// Schedule Local Notification
					self.scheduleLocalNotification()
				})
			case .authorized:
				// Schedule Local Notification
				self.scheduleLocalNotification()
			case .denied:
				print("Application Not Allowed to Display Notifications")
			}
		}
	}
	
	
	private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
		// Request Authorization
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
			if let error = error {
				print("Request Authorization Failed (\(error), \(error.localizedDescription))")
			}
			
			completionHandler(success)
		}
	}
	
	private func scheduleLocalNotification() {
		// Create Notification Content
		let notificationContent = UNMutableNotificationContent()
		
		// Configure Notification Content
		notificationContent.title = "Queue Gate"
		notificationContent.subtitle = "Local Notifications"
		notificationContent.body = "You have checked in a queue!"
		
		
		// Add Trigger
		let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
		
		// Create Notification Request
		let notificationRequest = UNNotificationRequest(identifier: "queue_gate_local_notification", content: notificationContent, trigger: notificationTrigger)
		
		// Add Request to User Notification Center
		UNUserNotificationCenter.current().add(notificationRequest) { (error) in
			if let error = error {
				print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
			}
		}
	}

}
