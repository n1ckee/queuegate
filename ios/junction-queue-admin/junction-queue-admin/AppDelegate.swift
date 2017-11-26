//
//  AppDelegate.swift
//  junction-queue-admin
//
//  Created by Dmitry Latnikov on 11/25/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase
import CoreBluetooth
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CBPeripheralManagerDelegate {

	var localBeacon: CLBeaconRegion!
	var beaconPeripheralData: NSDictionary!
	var peripheralManager: CBPeripheralManager!
	
	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		FirebaseApp.configure()
		
		window = UIWindow()
		window?.makeKeyAndVisible()
		
		initLocalBeacon()
		notification()
		
		if AuthenticationService.isAuthenticated() {
			let listQueuesController = ListQueuesController()
			let navController = UINavigationController(rootViewController: listQueuesController)
			window?.rootViewController = navController
		} else {
			let loginController = LoginController()
			let navController = UINavigationController(rootViewController: loginController)
			window?.rootViewController = navController
		}
		window?.makeKeyAndVisible()
		
		// Override point for customization after application launch.
		return true
	}


	func initLocalBeacon() {
		print("Beacon init")
		
		if localBeacon != nil {
			stopLocalBeacon()
		}
		
		let localBeaconUUID = "B0702880-A295-A8AB-F734-031A98A512DE"
		let localBeaconMajor: CLBeaconMajorValue = 5
		let localBeaconMinor: CLBeaconMinorValue = 1000
		
		let uuid = UUID(uuidString: localBeaconUUID)!
		localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Your private identifer here")
		
		beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
		peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
		
		print("Beacon initialized")
	}
	
	func stopLocalBeacon() {
		peripheralManager.stopAdvertising()
		peripheralManager = nil
		beaconPeripheralData = nil
		localBeacon = nil
		
		print("Stopped local beacon")
	}
	
	func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		if peripheral.state == .poweredOn {
			peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
			print("Started advertising")
		} else if peripheral.state == .poweredOff {
			peripheralManager.stopAdvertising()
			print("Stopped advertising")
		}
	}
	
	func notification() {
		
		let content = UNMutableNotificationContent()
		content.title = "Forget Me Not"
		content.body = "Are you forgetting something?"
		content.sound = .default()
		
		let request = UNNotificationRequest(identifier: "ForgetMeNot", content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
	}

}

