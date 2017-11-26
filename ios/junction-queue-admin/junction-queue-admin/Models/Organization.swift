//
//  Organizations.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import Firebase

struct Organization {
	
	private var documentId: String?
	
	var id: String? {
		return documentId
	}
	var name: String
	var address: String
	
	var dictionary: [String: Any] {
		return [
			"name": name,
			"address": address
		]
	}
	
}

extension Organization : DocumentSerializable {
	init?(dictionary: [String : Any]) {
		guard let name = dictionary["name"] as? String,
			let address = dictionary["address"] as? String else {return nil}
		
		self.init(documentId: nil, name: name, address: address)
	}
	
	init?(id: String, dictionary: [String : Any]) {
		guard let name = dictionary["name"] as? String,
			let address = dictionary["address"] as? String else {return nil}
		
		self.init(documentId: id, name: name, address: address)
	}
}

