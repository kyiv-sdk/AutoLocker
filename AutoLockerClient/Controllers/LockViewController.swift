//
//  ViewController.swift
//  AutoLockerClient
//
//  Created by Admin on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit
import LocalAuthentication

fileprivate let kLockUnlockReason = "To lock/unlock Mac, application needs to make sure that you are a confidant."
fileprivate let kChangeSettingsReason = "To access AutoLocker settings, application needs to make sure that you are device owner."

class LockViewController: UIViewController {

    private var authManager: LAManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        let policy = UserDefaultsManager.sharedInstance.laPolicy
        self.authManager = LAManager(policy: policy)
    }

    @IBAction func unlockMacButtonPressed(_ sender: UIButton) {
        self.askPermission(onSuccess: {
            // TODO: Send request with pwd to Mac
        }, onFail: {
            // TODO: Handle unauthorized case
        })
    }


    @IBAction func lockMacButtonPressed(_ sender: UIButton) {
        self.askPermission(onSuccess: {
            // TODO: Send lock request to Mac
        }, onFail: {
            // TODO: Handle unauthorized case
        })
    }

    @IBAction func showAutoLockerSettingsButtonPressed(_ sender: UIButton) {
        self.authManager.authorizeDeviceOwnerWithReason(kLockUnlockReason) { [weak self] (success, error) in
            if let error = error { self?.showInfoAlert(title: "Error", message: error.localizedDescription) }
            if success {
                self?.performSegue(withIdentifier: "ShowAutoLockerSettings", sender: self)
            }
        }

    }



    private func askPermission(onSuccess: @escaping () -> Void, onFail: @escaping () -> Void) -> Void {
        self.authManager.authorizeUserWithReason(kLockUnlockReason) { [weak self] (success, error) in
            if success { onSuccess() }
            else {
                if let error = error { self?.showInfoAlert(title: String.appName, message: error.localizedDescription) }
                onFail()
            }
        }
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAutoLockerSettings" {
            let destination = segue.destination as! AutoLockerSettingsController
            destination.setLAManager(self.authManager)
        }
    }

}
