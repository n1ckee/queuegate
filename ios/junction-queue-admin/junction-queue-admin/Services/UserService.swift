//
//  UserService.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import Firebase

class UserService {
	
	private let db: Firestore
	
	static let shared = UserService()
	
	private init() {
		db = Firestore.firestore()
	}
	
	func getAuthenticatedUserTicketCount(completion: @escaping (_ count: Int) -> Void) {

		guard let userId = AuthenticationService.getUserUid() else {
			FirebaseCrashMessage("Failed to fetch userId from user defaults")
			fatalError()
		}
		
		db.collection("Tickets").whereField("user_id", isEqualTo: userId).getDocuments { (snapshot, error) in
			if let error = error {
				FirebaseCrashMessage("Failed to fetch user tickets: \(error.localizedDescription)")
				fatalError()
			}
			
			if let count = snapshot?.documents.count {
				completion(count)
				return
			}
			
			completion(0)
		}
		
	}
}
