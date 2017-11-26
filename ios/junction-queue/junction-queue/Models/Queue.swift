//
//  Queue.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import Firebase

struct Queue {
	
	private var documentId: String?
	
	var id: String? {
		return documentId
	}
	var currentTicketId: String
	var lastTicketNumber: Int?
	var name: String
	var organizationId: String
	var status: String
	
	var dictionary: [String: Any] {
		return [
			"current_ticket_id": currentTicketId,
			"last_ticket_number": lastTicketNumber as Any,
			"name": name,
			"organization_id": organizationId,
			"status": status
		]
	}
	
}

extension Queue : DocumentSerializable {
	init?(dictionary: [String : Any]) {
		guard let currentTicketId = dictionary["current_ticket_id"] as? String,
			let lastTicketNumber = dictionary["last_ticket_number"] as? Int,
			let name = dictionary["name"] as? String,
			let organizationId = dictionary["organization_id"] as? String,
			let status = dictionary["status"] as? String
			else {return nil}
		
		self.init(documentId: nil, currentTicketId: currentTicketId, lastTicketNumber: lastTicketNumber, name: name, organizationId: organizationId, status: status)
	}
	
	init?(documentId: String, dictionary: [String : Any]) {
		guard let currentTicketId = dictionary["current_ticket_id"] as? String,
			let lastTicketNumber = dictionary["last_ticket_number"] as? Int,
			let name = dictionary["name"] as? String,
			let organizationId = dictionary["organization_id"] as? String,
			let status = dictionary["status"] as? String
			else {return nil}
		
		self.init(documentId: documentId, currentTicketId: currentTicketId, lastTicketNumber: lastTicketNumber, name: name, organizationId: organizationId, status: status)
	}
}

