//
//  AutoLockerSettingsController.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit
import LocalAuthentication

fileprivate let kMacPasswordAlertMessage = "To unclock your Mac, application should know its Password. Please enter password in Text Field below."
fileprivate let kMacSecretKeyAlertMessage = "To identify your Mac, application should know its Secret Key. Please enter Secret Key in Text Field below."

class AutoLockerSettingsController: UIViewController {
    
    private var authManager: LAManager!
    private var enteredPassword: String?
    private var enteredSecretKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enteredPassword = UserDefaultsManager.sharedInstance.macPassword
        self.enteredSecretKey = UserDefaultsManager.sharedInstance.macSecretKey
    }
    
    
    
    @IBAction func policySwitcherValueChanged(_ sender: UISwitch) {
        if sender.isOn { authManager.policy = LAManager.strictestPolicy }
        else { authManager.policy = LAPolicy(rawValue: 2)! }
    }
    
    
    @IBAction func setPasswortButtonPressed(_ sender: UIButton) {
        self.showTextFieldAlertWithTitle("Mac Password", message: kMacPasswordAlertMessage, andPlaceholder: "password") { [weak self] (password) in
            guard let weakSelf = self else { return }
            if let password = password {
                UserDefaultsManager.sharedInstance.macPassword = password
                weakSelf.enteredPassword = password
                weakSelf.updateMacSettings()
            }
        }
    }
    
    
    @IBAction func setSecretKeyButtonPressed(_ sender: UIButton) {
        self.showTextFieldAlertWithTitle("Secret Key", message: kMacSecretKeyAlertMessage, andPlaceholder: "key") { [weak self] (key) in
            guard let weakSelf = self else { return }
        
            var message: String?
            if let key = key,
                key.isSecretKeyLongEnough(errorMessage: &message),
                key.isSecretKeyAlphanumeric(errorMessage: &message) {
                UserDefaultsManager.sharedInstance.macSecretKey = key
                weakSelf.enteredSecretKey = key
                weakSelf.updateMacSettings()
            } else if let message = message {
                self?.showInfoAlert(title: String.appName, message: message)
            }
        }
    }
    
    
    
    private func showTextFieldAlertWithTitle(_ title: String, message: String, andPlaceholder placeholder:String, completion handler: @escaping (String?) -> Void) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let text = alert?.textFields?[0].text {
                handler(text)
            } else {
                handler(nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func updateMacSettings() -> Void {
        if let password = enteredPassword, let key = enteredSecretKey {
            let manager = BLEManager.sharedInstance
            manager.addConfiguration(macConfiguration: MacConfiguration(password: password, secret: key))
        }
    }
    
    func setLAManager(_ manager: LAManager) -> Void {
        self.authManager = manager
    }
    
}
