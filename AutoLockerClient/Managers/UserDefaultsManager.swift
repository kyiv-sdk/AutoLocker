//
//  UserDefaultsManager.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/25/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit
import LocalAuthentication

class UserDefaultsManager {
    
    var macPassword: String? {
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.MacPasswordKey) as? String }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.MacPasswordKey) }
    }

    
    var macSecretKey: String? {
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SecretKeyKey) as? String }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.SecretKeyKey) }
    }

    
    var laPolicy: LAPolicy {
        get {
            if let rawValue = UserDefaults.standard.value(forKey: UserDefaultsKeys.LAPolicyKey) as? Int {
                return LAPolicy.init(rawValue: rawValue)!
            }
            return LAManager.strictestPolicy
        }
        set { UserDefaults.standard.setValue(newValue.rawValue, forKey: UserDefaultsKeys.LAPolicyKey) }
    }
    
    
    func saveMacConfiguration(_ configuration: MacConfiguration) -> Void {
        self.macPassword = configuration.password
        self.macSecretKey = configuration.secret
    }
    
    
    func getMacConfiguration() -> MacConfiguration? {
        if let pwd = self.macPassword, let secret = self.macSecretKey {
            return MacConfiguration(password: pwd, secret: secret)
        }
        return nil
    }
    

    static let sharedInstance = UserDefaultsManager()
}


fileprivate enum UserDefaultsKeys {
    static let MacPasswordKey = "kMacPassword"
    static let SecretKeyKey = "kMacSecretKey"
    static let LAPolicyKey = "kLAManagerPolicy"
}
