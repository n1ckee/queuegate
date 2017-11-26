//
//  ViewQueueController.swift
//  junction-queue-admin
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

class ViewQueueController: UIViewController {

	var queue: Queue? {
		
		didSet {
			queueNameLabel.text = queue?.name
		}
	}
	
	private var queueSnapshotListener: ListenerRegistration?
	
	let queueNameLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 20)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let currentTicketLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 32)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let nextTicketButton: UIButton = {
		let button = UIButton()
		button.setTitle("Call in next ticket", for: UIControlState.normal)
		button.setTitleColor(UIColor.blue, for: .normal)
		button.addTarget(self, action: #selector(callInNextTicket), for: .touchUpInside)
		
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Queue management"
		view.backgroundColor = .white
		
		setupUI()
		
		setCurrentTicket()
    }

	private func setupUI() {
		view.addSubview(queueNameLabel)
		queueNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
		queueNameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
		queueNameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
		
		view.addSubview(currentTicketLabel)
		currentTicketLabel.topAnchor.constraint(equalTo: queueNameLabel.bottomAnchor, constant: 16).isActive = true
		currentTicketLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
		currentTicketLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
		
		view.addSubview(nextTicketButton)
		nextTicketButton.topAnchor.constraint(equalTo: currentTicketLabel.bottomAnchor, constant: 32).isActive = true
		nextTicketButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
		nextTicketButton.widthAnchor.constraint(equalToConstant: 150)
	}
	
	@objc private func callInNextTicket() {
		print("Calling in next ticket")
		
		guard let currentQueueId = queue?.id else {
			return
		}
		
		guard let currentQueue = queue else {
			return
		}
		
		let db = Firestore.firestore()
		
		if currentQueue.currentTicketId != "" {
			// currentTicketNumber = "5"
			db.collection("Tickets").document(currentQueue.currentTicketId).getDocument(completion: { (snapshot, error) in
				
				guard let snapshot = snapshot, snapshot.exists else {
					FirebaseCrashMessage("Failed to get snapshot")
					fatalError()
				}
				
				if let ticket = Ticket(documentId: snapshot.documentID, dictionary: snapshot.data()) {
					
					db.collection("Tickets").whereField("ticket_number", isGreaterThan: ticket.ticketNumber).whereField("queue_id", isEqualTo: currentQueueId).whereField("user_status", isEqualTo: "checked").order(by: "ticket_number").limit(to: 1).getDocuments { (snapshot, error) in
						if let error = error {
							print("Error: \(error)")
							db.collection("Queues").document(currentQueueId).updateData(["current_ticket_id" : ""])
							return
						}
						
						guard let snapshot = snapshot else {
							FirebaseCrashMessage("Failed to get snapshot")
							fatalError()
						}
						
						if (snapshot.documents.count != 1) {
							db.collection("Queues").document(currentQueueId).updateData(["current_ticket_id" : ""])
							return
						}
						
						if let nextTicket = Ticket(documentId: snapshot.documents[0].documentID, dictionary: snapshot.documents[0].data()) {
							db.collection("Queues").document(currentQueueId).updateData(["current_ticket_id" : nextTicket.id!])
							db.collection("TicketStatus").document(nextTicket.id!).updateData(["status" : "called"])
						}
					}
				}
			})
		} else {
			db.collection("Tickets").whereField("ticket_number", isGreaterThan: 0).whereField("queue_id", isEqualTo: currentQueueId).whereField("user_status", isEqualTo: "checked").order(by: "ticket_number").limit(to: 1).getDocuments { (snapshot, error) in
				if error != nil {
					print("Error: \(error)")
					db.collection("Queues").document(currentQueueId).updateData(["current_ticket_id" : ""])
					return
				}
				
				guard let snapshot = snapshot else {
					FirebaseCrashMessage("Failed to get snapshot")
					fatalError()
				}
				
				if (snapshot.documents.count != 1) {
					db.collection("Queues").document(currentQueueId).updateData(["current_ticket_id" : ""])
					return
				}
				
				if let nextTicket = Ticket(documentId: snapshot.documents[0].documentID, dictionary: snapshot.documents[0].data()) {
					db.collection("Queues").document(currentQueueId).updateData(["current_ticket_id" : nextTicket.id!])
					db.collection("TicketStatus").document(nextTicket.id!).updateData(["status" : "called"])
				}
			}
		}
	}
	
	private func setCurrentTicket() {
		queueSnapshotListener?.remove()
		
		guard let currentQueueId = queue?.id else {
			return
		}
		
		let db = Firestore.firestore()
		
		queueSnapshotListener = db.collection("Queues").document(currentQueueId).addSnapshotListener { (snapshot, error) in
			if let error = error {
				print("Error: \(error)")
				fatalError()
			}
			
			guard let snapshot = snapshot, snapshot.exists else {
				FirebaseCrashMessage("Failed to get snapshot")
				fatalError()
			}
			
			if let queue = Queue(documentId: snapshot.documentID, dictionary: snapshot.data()) {
				
				if queue.currentTicketId != "" {
					self.queue = queue
					
					db.collection("Tickets").document(queue.currentTicketId).getDocument(completion: { (snapshot, error) in
						
						guard let snapshot = snapshot, snapshot.exists else {
							FirebaseCrashMessage("Failed to get snapshot")
							fatalError()
						}
						
						if let ticket = Ticket(documentId: snapshot.documentID, dictionary: snapshot.data()) {
							self.currentTicketLabel.text = "Current ticket: \(ticket.ticketNumber)"
						}
					})
				} else {
					self.currentTicketLabel.text = "Current ticket: none"
				}
				
			} else {
	
				FirebaseCrashMessage("Failed to create queue object")
				fatalError()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		queueSnapshotListener?.remove()
	}
}
