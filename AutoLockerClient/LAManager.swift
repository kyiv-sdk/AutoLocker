//
//  LAManager.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import LocalAuthentication

class LAManager {
    
    private var context: LAContext
    private var _policy: LAPolicy
    public var policy: LAPolicy {
        get {
            return _policy
        }
        
        set {
            if newValue != _policy {
                self.authorizeDeviceOwnerWithRason { [weak self] (success) in
                    guard let weakSelf = self, success else { return }
                    weakSelf._policy = newValue
                }
            }
        }
    }
    
    
    
    init(policy: LAPolicy) {
        self.context = LAContext()
        self._policy = policy
    }
    
    
    
    func authorizeUserWithRason(_ reason: String, completion handler: @escaping (Bool) -> Void) -> Void {
        self.authorizeUserWith(_policy, reason: reason) { (success) in
            handler(success)
        }
    }
    
    
    private func authorizeDeviceOwnerWithRason(completion handler: @escaping (Bool) -> Void) -> Void {
        self.authorizeUserWith(.deviceOwnerAuthenticationWithBiometrics, reason: "Only device owner can change LAPolicy.") { (success) in
            handler(success)
        }
    }
    
    private func authorizeUserWith(_ policy: LAPolicy, reason: String, completion handler: @escaping (Bool) -> Void) -> Void {
        self.context.evaluatePolicy(policy, localizedReason: reason) { (success, _) in
            handler(success)
        }
    }
    
}
