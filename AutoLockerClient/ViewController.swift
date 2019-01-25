//
//  ViewController.swift
//  AutoLockerClient
//
//  Created by Admin on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit
import LocalAuthentication

fileprivate let userDefaultsKeyLAPolicy = "kLAManagerPolicy"
fileprivate let kLockUnlockReason = "To lock/unlock Mac, application needs to make sure that you are a confidant."

class ViewController: UIViewController {
    
    private var authManager: LAManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        let policyRawValue = UserDefaults.standard.value(forKey: userDefaultsKeyLAPolicy) as? Int
        let policy = LAPolicy(rawValue: policyRawValue ?? 1)!
        self.authManager = LAManager(policy: policy)
    }

    @IBAction func unlockMacButtonPressed(_ sender: UIButton) {
        self.authManager.authorizeUserWithReason(kLockUnlockReason) { [weak self] (authorized) in
            guard let weakSelf = self else { return }
            if authorized {
                // TODO: Send request with pwd to Mac
            } else {
                // TODO: Handle unauthorized case
            }
        }
    }
    
    
    @IBAction func lockMacButtonPressed(_ sender: UIButton) {
        self.authManager.authorizeUserWithReason(kLockUnlockReason) { [weak self] (authorized) in
            guard let weakSelf = self else { return }
            if authorized {
                // TODO: Send lock request to Mac
            } else {
                // TODO: Handle unauthorized case
            }
        }
    }
    
}

