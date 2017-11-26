//
//  TakeTicketController.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

class TakeTicketController: UIViewController {

	var organization: Organization?
	var queueId: String!
	private let db = Firestore.firestore()
	private var queueRef: DocumentReference!
	private var queueSnapshotListener: ListenerRegistration!
	private var ticketSnapshotListener: ListenerRegistration?
	private var queue: Queue!
	
	// MARK: Initialization
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Take ticket"
        view.backgroundColor = .white
		
		queueRef = db.collection("Queues").document(queueId)
		queueSnapshotListener = queueRef.addSnapshotListener { (snapshot, error) in
			if let error = error {
				FirebaseCrashMessage("Failed to add listener: \(error)")
				fatalError()
			}
			
			guard let snapshot = snapshot, snapshot.exists else {
				FirebaseCrashMessage("Failed to set snapshot or it does not exist")
				fatalError()
			}
			
			if let queue = Queue(documentId: snapshot.documentID, dictionary: snapshot.data()) {
				self.queue = queue
				
				if let ticketNumber = queue.lastTicketNumber {
					self.lastTicketLabel.text = "/ \(ticketNumber)"
				}
				
				self.queueNameLabel.text = queue.name
				self.createCurrentTicketNumberListener(ticketId: queue.currentTicketId)
			} else {
				FirebaseCrashMessage("Failed to create queue object")
				fatalError()
			}
		}
		
		organizationNameLabel.text = organization?.name
		
		setupUiElements()
    }

	private func createCurrentTicketNumberListener(ticketId: String) {
		
		if ticketId == "" {
			self.currentTicketLabel.text = ""
			return
		}
		
		ticketSnapshotListener = db.collection("Tickets").document(ticketId).addSnapshotListener { (snapshot, error) in
			if let error = error {
				FirebaseCrashMessage("Failed to add listener: \(error)")
				fatalError()
			}
			
			guard let snapshot = snapshot, snapshot.exists else {
				FirebaseCrashMessage("Failed to get snapshot: \(error)")
				fatalError()
			}
			
			if let ticket = Ticket(documentId: snapshot.documentID, dictionary: snapshot.data()) {
				self.currentTicketLabel.text = "\(ticket.ticketNumber)"
			} else {
				
				FirebaseCrashMessage("Failed to create ticket object")
				fatalError()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		queueSnapshotListener.remove()
		ticketSnapshotListener?.remove()
	}
	
	var seconds = 0
	var timer: Timer!
	
	let backgroundColorView: UIView = {
		let background = UIView()
		background.clipsToBounds = true
		background.translatesAutoresizingMaskIntoConstraints = false
		return background
	}()
	
	let organizationNameLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let queueNameLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let currentTicketLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 72)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let lastTicketLabel: UILabel = {
		let label = UILabel()
		label.text = "/ 15"
		label.font = UIFont.boldSystemFont(ofSize: 36)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let estimatedTimeLeftLabel: UILabel = {
		let label = UILabel()
		label.text = "Est. time in queue: "
		label.font = UIFont.systemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let timerLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let takeTicketButton: UIButton = {
		let button = UIButton()
		button.setTitle("Take ticket", for: UIControlState.normal)
		button.setTitleColor(UIColor.blue, for: .normal)
		button.addTarget(self, action: #selector(handleTakeTicket), for: .touchUpInside)
		
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	@objc private func handleTakeTicket() {
		print("take ticket")
		
		guard let userId = AuthenticationService.getUserUid() else {
			return
		}
		
		let url = URL(string: "https://us-central1-noqueue-185020.cloudfunctions.net/getTicket")!
		var request = URLRequest(url: url)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		let bodyData: [String : String] = ["user_id": userId as String, "queue_id": queueId]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)
		} catch let error {
			print(error.localizedDescription)
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if error != nil {
				FirebaseCrashMessage("Error when creating data task: \(error?.localizedDescription ?? "")")
				fatalError()
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				FirebaseCrashMessage("statusCode should be 200, but is \(httpStatus.statusCode)")
				fatalError()
			}
			
//			let responseString = String(data: data, encoding: .utf8)
			OperationQueue.main.addOperation {
				let listTicketsController = ListTicketsController()
				let navController = UINavigationController(rootViewController: listTicketsController)
				UIApplication.shared.keyWindow?.rootViewController = navController
			}
		}.resume()
	}
	
	private func setupUiElements() {
		view.addSubview(backgroundColorView)
		backgroundColorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
		backgroundColorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
		backgroundColorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
		backgroundColorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -18).isActive = true
		
		view.addSubview(organizationNameLabel)
		organizationNameLabel.leftAnchor.constraint(equalTo: backgroundColorView.leftAnchor, constant: 8).isActive = true
		organizationNameLabel.rightAnchor.constraint(equalTo: backgroundColorView.rightAnchor, constant: -8).isActive = true
		organizationNameLabel.topAnchor.constraint(equalTo: backgroundColorView.topAnchor, constant: 8).isActive = true
		organizationNameLabel.heightAnchor.constraint(equalToConstant: 20)
		
		view.addSubview(queueNameLabel)
		queueNameLabel.leftAnchor.constraint(equalTo: backgroundColorView.leftAnchor, constant: 8).isActive = true
		queueNameLabel.rightAnchor.constraint(equalTo: backgroundColorView.rightAnchor, constant: -8).isActive = true
		queueNameLabel.topAnchor.constraint(equalTo: organizationNameLabel.bottomAnchor, constant: 8).isActive = true
		
		view.addSubview(currentTicketLabel)
		currentTicketLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		currentTicketLabel.topAnchor.constraint(equalTo: queueNameLabel.topAnchor, constant: 30).isActive = true
		currentTicketLabel.heightAnchor.constraint(equalToConstant: 66).isActive = true
		
		view.addSubview(lastTicketLabel)
		lastTicketLabel.leftAnchor.constraint(equalTo: currentTicketLabel.rightAnchor, constant: 16).isActive = true
		lastTicketLabel.bottomAnchor.constraint(equalTo: currentTicketLabel.bottomAnchor).isActive = true
		
		view.addSubview(takeTicketButton)
		takeTicketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		takeTicketButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
		takeTicketButton.topAnchor.constraint(equalTo: lastTicketLabel.bottomAnchor, constant: 30).isActive = true
		
		
//		view.addSubview(estimatedTimeLeftLabel)
//		estimatedTimeLeftLabel.leftAnchor.constraint(equalTo: backgroundColorView.leftAnchor, constant: 8).isActive = true
//		estimatedTimeLeftLabel.topAnchor.constraint(equalTo: lastTicketNumberLabel.bottomAnchor, constant: 30).isActive = true
//
//		view.addSubview(timerLabel)
//		timerLabel.leftAnchor.constraint(equalTo: estimatedTimeLeftLabel.rightAnchor).isActive = true
//		timerLabel.bottomAnchor.constraint(equalTo: estimatedTimeLeftLabel.bottomAnchor).isActive = true
	}
	
	// MARK: timer update
	private func updateTimerLabel() {
		let now = Date()
		seconds += 1
		
//		if let approxDate = queue. {
//			let secondsUntilQueue = Int(approxDate.timeIntervalSince(now))
//
//			if secondsUntilQueue <= 0 {
//				timer.invalidate()
//			}
//
//			let formatter = DateComponentsFormatter()
//			formatter.allowedUnits = [.hour, .minute, .second]
//			formatter.unitsStyle = .brief
//
//			let formattedString = formatter.string(from: TimeInterval(secondsUntilQueue))!
//			self.timerLabel.text = formattedString
//		}
		
	}
}
