//
//  LAManager.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import LocalAuthentication

class LAManager {
    private var _policy: LAPolicy
    public var policy: LAPolicy {
        get {
            return _policy
        }
        
        set {
            if newValue != _policy {
                self.authorizeDeviceOwnerWithReason { [weak self] (success, error) in
                    guard let weakSelf = self, success else { return }
                    weakSelf._policy = newValue
                }
            }
        }
    }
    
    init(policy: LAPolicy) {
        self._policy = policy
    }
    
    func authorizeUserWithReason(_ reason: String, completion handler: @escaping (Bool, NSError?) -> Void) -> Void {
        self.authorizeUserWith(_policy, reason: reason) { (success, error) in
            handler(success, error)
        }
    }
    
    private func authorizeDeviceOwnerWithReason(completion handler: @escaping (Bool, NSError?) -> Void) -> Void {
        self.authorizeUserWith(.deviceOwnerAuthenticationWithBiometrics, reason: "Only device owner can change LAPolicy.") { (success, error) in
            handler(success, error)
        }
    }
    
    private func authorizeUserWith(_ policy: LAPolicy, reason: String, completion handler: @escaping (Bool, NSError?) -> Void) -> Void {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(policy, error: &error) else {
            handler(false, error)
            return
        }
        
        context.evaluatePolicy(policy, localizedReason: reason) { (success, evaluationError) in
            handler(success, evaluationError as NSError?)
        }
    }
    
}
