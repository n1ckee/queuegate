//
//  AuthenticationService.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation

class AuthenticationService {
	
	private static let userIdKey: String = "userId"
	private static let nameKey: String = "name"
	private static let emailKey: String = "email"
	private static let organizationIdKey: String = "organizationId"
	
	static func isAuthenticated() -> Bool {
		let defaults = UserDefaults.standard
		
		if defaults.string(forKey: userIdKey) != nil {
			return true
		}
		return false
	}
	
	static func getUserUid() -> String? {
		let defaults = UserDefaults.standard
		
		if let userId = defaults.string(forKey: userIdKey) {
			return userId
		}
		return nil
	}
	
	static func getOrganizationId() -> String? {
		let defaults = UserDefaults.standard
		
		if let organizationId = defaults.string(forKey: organizationIdKey) {
			return organizationId
		}
		return nil
	}
	
	static func authenticate(userUid: String, name: String, email: String, organizationId: String) {
		let defaults = UserDefaults.standard
		
		defaults.set(userUid, forKey: userIdKey)
		defaults.set(name, forKey: nameKey)
		defaults.set(email, forKey: emailKey)
		defaults.set(organizationId, forKey: organizationIdKey)
	}
}
