//
//  AlertsUIViewControllerExtension.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func displayAlert(title: String?, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                DispatchQueue.main.async {
                    alertController.dismiss(animated: true, completion: nil)
                }
            })
    
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
