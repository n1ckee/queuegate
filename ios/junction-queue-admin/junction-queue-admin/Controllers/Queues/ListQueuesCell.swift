//
//  ListQueuesCell.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import UIKit

class ListQueuesCell: UITableViewCell {
	
	var queue: Queue? {
		didSet {
			let countOfActiveTickets = queue?.ticketCount ?? 0
			nameLabel.text = "\(queue?.name ?? "") (\(countOfActiveTickets) Active tickets)"
		}
	}
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 26)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .white
		
		addSubview(nameLabel)
		nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
		nameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
