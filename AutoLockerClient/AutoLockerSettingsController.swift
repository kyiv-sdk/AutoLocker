//
//  AutoLockerSettingsController.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit

fileprivate let userDefaultsKeyMacPassword = "kMacPassword"
fileprivate let userDefaultsKeyMacSecretKey = "kMacSecretKey"

fileprivate let kMacPasswordAlertMessage = "To unclock your Mac, application should know its Password. Please enter password in Text Field below."
fileprivate let kMacSecretKeyAlertMessage = "To identify your Mac, application should know its Secret Key. Please enter Secret Key in Text Field below."

class AutoLockerSettingsController: UIViewController {
    
    private var enteredPassword: String?
    private var enteredSecretKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enteredPassword = UserDefaults.standard.value(forKey: userDefaultsKeyMacPassword) as? String
        self.enteredSecretKey = UserDefaults.standard.value(forKey: userDefaultsKeyMacSecretKey) as? String
    }
    
    
    
    @IBAction func setPasswortButtonPressed(_ sender: UIButton) {
        self.showTextFieldAlertWithTitle("Mac Password", message: kMacPasswordAlertMessage, andPlaceholder: "password") { [weak self] (password) in
            guard let weakSelf = self else { return }
            if let password = password {
                weakSelf.enteredPassword = password
                UserDefaults.standard.setValue(password, forKey: userDefaultsKeyMacPassword)
                weakSelf.updateMacSettings()
            }
        }
    }
    
    
    @IBAction func setSecretKeyButtonPressed(_ sender: UIButton) {
        self.showTextFieldAlertWithTitle("Secret Key", message: kMacSecretKeyAlertMessage, andPlaceholder: "key") { [weak self] (key) in
            guard let weakSelf = self else { return }
            if let key = key {
                weakSelf.enteredSecretKey = key
                UserDefaults.standard.setValue(key, forKey: userDefaultsKeyMacSecretKey)
                weakSelf.updateMacSettings()
            }
        }
    }
    
    
    
    func showTextFieldAlertWithTitle(_ title: String, message: String, andPlaceholder placeholder:String, completion handler: @escaping (String?) -> Void) -> Void {
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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            handler(nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func updateMacSettings() -> Void {
        if let password = enteredPassword, let key = enteredSecretKey {
            let manager = BLEManager.sharedInstance
            manager.addConfiguration(macConfiguration: MacConfiguration(password: password, secret: key))
        }
    }
    
}
