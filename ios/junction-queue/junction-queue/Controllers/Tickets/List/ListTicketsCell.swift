//
//  ListTicketsCell.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

class ListTicketsCell: UITableViewCell {
	
	var organization: Organization? {
		
		didSet {
			organizationNameLabel.text = organization?.name
		}
	}
	
	var queue: Queue? {
		
		didSet {
			queueNameLabel.text = queue?.name
			
			if let currentTicketId = queue?.currentTicketId {
				setCurrentQueueTicket(currentTicketId)
			}
		}
	}
	
	var ticket: Ticket? {
		
		didSet {
			queueNameLabel.text = "Queue name"
			organizationNameLabel.text = "Organization name"
			
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
			
			guard let ticketNumber = ticket?.ticketNumber else {
				return
			}
			
			ticketNumberLabel.text = "/ \(ticketNumber)"
		}
	}
	
	var seconds = 0
	var timer: Timer!
	
	let backgroundColorView: UIView = {
		let background = UIView()
		background.backgroundColor = UIColor.white
		background.layer.cornerRadius = 10
		background.clipsToBounds = true
		background.layer.borderColor = UIColor.darkGray.cgColor
		background.layer.borderWidth = 1
		background.translatesAutoresizingMaskIntoConstraints = false
		return background
	}()
	
	let organizationNameLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let queueNameLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let currentTicketNumberLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 72)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let ticketNumberLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 36)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let estimatedTimeLeftLabel: UILabel = {
		let label = UILabel()
		label.text = "Est. time in queue: "
		label.font = UIFont.systemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let timerLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		addSubview(backgroundColorView)
		backgroundColorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		backgroundColorView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		backgroundColorView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
		backgroundColorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
		
		addSubview(organizationNameLabel)
		organizationNameLabel.leftAnchor.constraint(equalTo: backgroundColorView.leftAnchor, constant: 8).isActive = true
		organizationNameLabel.rightAnchor.constraint(equalTo: backgroundColorView.rightAnchor, constant: 8).isActive = true
		organizationNameLabel.topAnchor.constraint(equalTo: backgroundColorView.topAnchor, constant: 8).isActive = true
		organizationNameLabel.heightAnchor.constraint(equalToConstant: 20)
		
		addSubview(queueNameLabel)
		queueNameLabel.leftAnchor.constraint(equalTo: backgroundColorView.leftAnchor, constant: 8).isActive = true
		queueNameLabel.rightAnchor.constraint(equalTo: backgroundColorView.rightAnchor, constant: -8).isActive = true
		queueNameLabel.topAnchor.constraint(equalTo: organizationNameLabel.bottomAnchor, constant: 8).isActive = true
		queueNameLabel.heightAnchor.constraint(equalToConstant: 20)
		
		addSubview(currentTicketNumberLabel)
		currentTicketNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		//		userTicketNumberLabel.widthAnchor.constraint(equalToConstant: 110).isActive = true
		currentTicketNumberLabel.topAnchor.constraint(equalTo: queueNameLabel.bottomAnchor, constant: 15).isActive = true
		currentTicketNumberLabel.heightAnchor.constraint(equalToConstant: 66).isActive = true
		
		addSubview(ticketNumberLabel)
		ticketNumberLabel.leftAnchor.constraint(equalTo: currentTicketNumberLabel.rightAnchor, constant: 16).isActive = true
		//		currentTicketNumberLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
		ticketNumberLabel.bottomAnchor.constraint(equalTo: currentTicketNumberLabel.bottomAnchor).isActive = true
		//		currentTicketNumberLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
		
		addSubview(estimatedTimeLeftLabel)
		//		estimatedTimeLeftLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
		estimatedTimeLeftLabel.leftAnchor.constraint(equalTo: backgroundColorView.leftAnchor, constant: 8).isActive = true
		estimatedTimeLeftLabel.bottomAnchor.constraint(equalTo: backgroundColorView.bottomAnchor, constant: -8).isActive = true
		
		addSubview(timerLabel)
		//		estimatedTimeLeftLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
		timerLabel.leftAnchor.constraint(equalTo: estimatedTimeLeftLabel.rightAnchor).isActive = true
		timerLabel.bottomAnchor.constraint(equalTo: estimatedTimeLeftLabel.bottomAnchor).isActive = true
	}
	
	private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
		return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
	}
	
	@objc private func updateTimerLabel() {
		let now = Date()
		seconds += 1
		
		if let approxDate = ticket?.approxCallTime {
			let secondsUntilQueue = Int(approxDate.timeIntervalSince(now))
			
			if secondsUntilQueue <= 0 {
				timer.invalidate()
			}
			
			let formatter = DateComponentsFormatter()
			formatter.allowedUnits = [.hour, .minute, .second]
			formatter.unitsStyle = .brief
			
			let formattedString = formatter.string(from: TimeInterval(secondsUntilQueue))!
			
			//			let (h, m, s) = secondsToHoursMinutesSeconds(seconds: secondsUntilQueue)
			//			let timerString = String(format: "%i:%02i:%02i", h, m, s)
			//			self.timerLabel.text = timerString
			//			let (h, m, s) = secondsToHoursMinutesSeconds(seconds: secondsUntilQueue)
			self.timerLabel.text = formattedString
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setAsGetReadyForYourTurn() {
		backgroundColorView.backgroundColor = UIColor.green
	}
	
	private func setCurrentQueueTicket(_ currentTicketId: String) {
		if currentTicketId == "" {
			self.currentTicketNumberLabel.text = "none"
			return
		}
		
		let db = Firestore.firestore()
		
		db.collection("Tickets").document(currentTicketId).getDocument { (snapshot, error) in
			if let error = error {
				FirebaseCrashMessage("Could not fetch ticket: \(error)")
				fatalError()
			}
			
			if let snapshot = snapshot {
				if let ticket = Ticket(dictionary: snapshot.data()) {
					self.currentTicketNumberLabel.text = "\(ticket.ticketNumber)"
					
					if currentTicketId == self.ticket?.id {
						self.setAsGetReadyForYourTurn()
						return
					}
				}
			}
		}
	}
}
