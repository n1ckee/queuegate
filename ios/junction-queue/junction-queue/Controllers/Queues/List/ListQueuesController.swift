//
//  ListQueuesControllerTableViewController.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

class ListQueuesController: UITableViewController {

	var organization: Organization?
	private var organizationQueues = [Queue]()
	
	private let cellId = "cellId"
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Select queue"
		view.backgroundColor = .white
		
		tableView.register(ListQueuesCell.self, forCellReuseIdentifier: cellId)
		
		loadOrganizationQueues()
	}
	
	private func loadOrganizationQueues() {
		let db = Firestore.firestore()
		
		guard let organizationId = organization?.id else {
			FirebaseCrashMessage("Organization has no id assigned!")
			fatalError()
		}
		
		guard let userId = AuthenticationService.getUserUid() else {
			FirebaseCrashMessage("User id is undefined!")
			fatalError()
		}
		
		db.collection("Tickets").whereField("user_id", isEqualTo: userId).getDocuments { (querySnapshot, error) in
			if let error = error {
				print("Failed to fetch user tickets: \(error.localizedDescription)")
				return
			}
			
			if let snapshot = querySnapshot {
				var queueIdsToFilter = [String]()
				
				snapshot.documents.forEach({ (document) in
					if let ticket = Ticket(documentId: document.documentID, dictionary: document.data()) {
						queueIdsToFilter.append(ticket.queueId)
					} else {
						print("Failed to create queue object")
					}
				})
				
				// todo: extract to separate method
				db.collection("Queues").whereField("organization_id", isEqualTo: organizationId).getDocuments { (snapshot, error) in
					if let error = error {
						print("Failed to fetch organization queues: \(error.localizedDescription)")
						return
					}
					
					if let snapshot = snapshot {
						snapshot.documents.forEach({ (document) in
							if let queue = Queue(documentId: document.documentID, dictionary: document.data()) {
								if !queueIdsToFilter.contains(queue.id!) {
									self.organizationQueues.append(queue)
								}
							} else {
								print("Failed to create queue object")
							}
						})
						
						self.tableView.reloadData()
					}
				}
			}
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListQueuesCell
		cell.queue = organizationQueues[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return organizationQueues.count
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let queue = organizationQueues[indexPath.row]
		let takeTicketController = TakeTicketController()
		takeTicketController.queueId = queue.id
		takeTicketController.organization = organization
		self.navigationController?.pushViewController(takeTicketController, animated: true)
	}
}
