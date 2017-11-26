//
//  ListOrganizationsCell.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit

class ListOrganizationsCell: UITableViewCell {
	
	var organization: Organization? {
		didSet {
			nameLabel.text = organization?.name
			
//			if let imageData = company?.imageData {
//				companyImageView.image = UIImage(data: imageData)
//			}
		}
	}
	
	let companyImageView: UIImageView = {
		let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 20
		imageView.clipsToBounds = true
		imageView.layer.borderColor = UIColor.black.cgColor
		imageView.layer.borderWidth = 1
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Organization name"
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .white
		
		addSubview(companyImageView)
		companyImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		companyImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		companyImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		companyImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		addSubview(nameLabel)
		nameLabel.leftAnchor.constraint(equalTo: companyImageView.rightAnchor, constant: 8).isActive = true
		nameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

