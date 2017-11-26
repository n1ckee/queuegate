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

	private var organizationQueues = [Queue]()
	private var tickets = [Ticket]()
	
	private let cellId = "cellId"
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Select queue to manage"
		view.backgroundColor = .white
		
		tableView.register(ListQueuesCell.self, forCellReuseIdentifier: cellId)
		tableView.cellLayoutMarginsFollowReadableWidth = false
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		refreshControl.tintColor = .white
		self.refreshControl = refreshControl
		
		loadOrganizationQueues()
	}
	
	@objc private func handleRefresh() {
		print("Refresh")
		loadOrganizationQueues()
		refreshControl?.endRefreshing()
	}
	
	private func loadOrganizationQueues() {
		let db = Firestore.firestore()
		
		guard let organizationId = AuthenticationService.getOrganizationId() else {
			FirebaseCrashMessage("Organization id is undefined!")
			fatalError()
		}
		
		// todo: extract to separate method
		db.collection("Queues").whereField("organization_id", isEqualTo: organizationId).getDocuments { (snapshot, error) in
			if let error = error {
				print("Failed to fetch organization queues: \(error.localizedDescription)")
				return
			}
			
			if let snapshot = snapshot {
				self.organizationQueues = []
				snapshot.documents.forEach({ (document) in
					if var queue = Queue(documentId: document.documentID, dictionary: document.data()) {
						db.collection("TicketStatus").whereField("queue_id", isEqualTo: document.documentID).whereField("status", isEqualTo: "pending").getDocuments(completion: { (snapshot, error) in
							
							queue.ticketCount = snapshot?.documents.count
							self.organizationQueues.append(queue)
							
							self.tableView.reloadData()
						})
						
					} else {
						print("Failed to create queue object")
					}
				})
			}
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListQueuesCell
		cell.queue = organizationQueues[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return organizationQueues.count
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.separatorInset = UIEdgeInsets.zero
		cell.layoutMargins = UIEdgeInsets.zero
	}

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let queue = organizationQueues[indexPath.row]
		let viewQueueController = ViewQueueController()
		viewQueueController.queue = queue
		self.navigationController?.pushViewController(viewQueueController, animated: true)
	}

}
