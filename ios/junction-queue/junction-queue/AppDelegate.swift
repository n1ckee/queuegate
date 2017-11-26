//
//  AppDelegate.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
		
		window = UIWindow()
		window?.makeKeyAndVisible()
		
        if AuthenticationService.isAuthenticated() {
			let listTicketsController = ListTicketsController()
			let navController = UINavigationController(rootViewController: listTicketsController)
			window?.rootViewController = navController
        } else {
			let loginController = LoginController()
			let navController = UINavigationController(rootViewController: loginController)
			window?.rootViewController = navController
        }
        window?.makeKeyAndVisible()
        
        return true
    }

}

