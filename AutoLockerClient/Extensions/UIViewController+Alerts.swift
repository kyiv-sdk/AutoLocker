//
//  UIViewController+Alerts.swift
//  AutoLockerClient
//
//  Created by ysirko on 1/25/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showInfoAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


