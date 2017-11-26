//
//  DocumentSerializableProtocol.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation

protocol DocumentSerializable  {
	init?(dictionary: [String: Any])
}
