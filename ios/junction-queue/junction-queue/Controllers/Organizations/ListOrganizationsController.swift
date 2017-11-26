//
//  ListOrganizationsController.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

class ListOrganizationsController: UITableViewController {

	private let cellId = "cellId"
	private var organizations = [Organization]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select organization"
		view.backgroundColor = .white
		
		tableView.register(ListOrganizationsCell.self, forCellReuseIdentifier: cellId)
		
		loadOrganizations()
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
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListOrganizationsCell
		cell.organization = organizations[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return organizations.count
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let organization = organizations[indexPath.row]
		let listQueuesController = ListQueuesController()
		listQueuesController.organization = organization		
		self.navigationController?.pushViewController(listQueuesController, animated: true)
	}
}

