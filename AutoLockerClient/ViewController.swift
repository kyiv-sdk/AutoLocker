//
//  ViewController.swift
//  AutoLockerClient
//
//  Created by Admin on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // TODO: policy should be stored
    private var authManager: LAManager = LAManager(policy: .deviceOwnerAuthenticationWithBiometrics)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func unlockMacButtonPressed(_ sender: UIButton) {
        authManager.authorizeUserWithRason("") { [weak self] (authorized) in
            guard let weakSelf = self else { return }
            if authorized {
                // TODO: Send request with pwd to Mac
            } else {
                // TODO: Handle unauthorized case
            }
        }
    }
    
    
    @IBAction func lockMacButtonPressed(_ sender: UIButton) {
        authManager.authorizeUserWithRason("") { [weak self] (authorized) in
            guard let weakSelf = self else { return }
            if authorized {
                // TODO: Send lock request to Mac
            } else {
                // TODO: Handle unauthorized case
            }
        }
    }
    
}

