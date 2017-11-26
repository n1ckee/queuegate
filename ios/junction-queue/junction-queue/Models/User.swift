//
//  User.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import Firebase

struct User {
	
    var name: String
    var email: String
    var cardNumber: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email,
            "card_number": cardNumber
        ]
    }
    
}

extension User : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let cardNumber = dictionary ["card_number"] as? String else {return nil}
        
        self.init(name: name, email: email, cardNumber: cardNumber)
    }
}
