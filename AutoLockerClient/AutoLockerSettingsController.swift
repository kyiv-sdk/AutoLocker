//
//  AutoLockerSettingsController.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit

class AutoLockerSettingsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setPasswortButtonPressed(_ sender: UIButton) {
        self.showTextFieldAlertWithTitle("Mac Password", message: "", andPlaceholder: "password") { (password) in
            if let password = password {
                // TODO: handle entered password
            }
        }
    }
    
    
    @IBAction func setSecretKeyButtonPressed(_ sender: UIButton) {
        self.showTextFieldAlertWithTitle("Secret Key", message: "", andPlaceholder: "key") { (key) in
            if let key = key {
                // TODO: handle entered key
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
    
}
