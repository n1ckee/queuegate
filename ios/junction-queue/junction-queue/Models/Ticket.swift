//
//  Ticket.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import Firebase

struct Ticket {
	
	private var documentId: String?
	
	var id: String? {
		return documentId
	}
	var approxCallTime: Date
	var queueId: String
	var ticketNumber: Int
	var userStatus: String
	
	var dictionary: [String: Any] {
		return [
			"approx_call_time": approxCallTime,
			"queue_id": queueId,
			"ticket_number": ticketNumber,
			"user_status": userStatus
		]
	}
	
}

extension Ticket : DocumentSerializable {
	init?(dictionary: [String : Any]) {
		guard let approxCallTime = dictionary["approx_call_time"] as? Date,
			let queueId = dictionary["queue_id"] as? String,
			let ticketNumber = dictionary ["ticket_number"] as? Int,
			let userStatus = dictionary["user_status"] as? String
			else {return nil}
		
		self.init(documentId: nil, approxCallTime: approxCallTime, queueId: queueId, ticketNumber: ticketNumber, userStatus: userStatus)
	}
	
	init?(documentId: String, dictionary: [String : Any]) {
		guard let approxCallTime = dictionary["approx_call_time"] as? Date,
			let queueId = dictionary["queue_id"] as? String,
			let ticketNumber = dictionary ["ticket_number"] as? Int,
			let userStatus = dictionary["user_status"] as? String
			else {return nil}
		
		self.init(documentId: documentId, approxCallTime: approxCallTime, queueId: queueId, ticketNumber: ticketNumber, userStatus: userStatus)
	}
}

