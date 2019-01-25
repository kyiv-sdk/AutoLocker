//
//  LAManager.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import LocalAuthentication

class LAManager {
    public var policy: LAPolicy
    
    init(policy: LAPolicy) {
        self.policy = policy
    }
    
    func authorizeUserWithReason(_ reason: String, completion handler: @escaping (Bool, NSError?) -> Void) -> Void {
        self.authorizeUserWith(policy, reason: reason) { (success, error) in
            handler(success, error)
        }
    }
    
    func authorizeDeviceOwnerWithReason(_ reason: String, completion handler: @escaping (Bool, NSError?) -> Void) -> Void {
        self.authorizeUserWith(LAManager.strictestPolicy, reason: reason) { (success, error) in
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
            DispatchQueue.main.async {
                handler(success, evaluationError as NSError?)
            }
        }
    }
    
    
    static let strictestPolicy: LAPolicy = isBiometrySupported ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
    private static var isBiometrySupported: Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print(error?.localizedDescription ?? "")
            return false
        }
        let type = context.biometryType
        return type == .faceID || type == .touchID
    }
    
}
