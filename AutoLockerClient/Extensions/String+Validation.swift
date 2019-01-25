//
//  String+Validation.swift
//  AutoLockerClient
//
//  Created by ysirko on 1/25/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit

let secretKeyLength: Int = 6

extension String {
    
    func isSecretKeyLongEnough(errorMessage: inout String?) -> Bool {
        if (self.count != secretKeyLength) {
            errorMessage = "Please enter a string that is 6 characters long."
        }
        return self.count == secretKeyLength
    }
    
    func isSecretKeyAlphanumeric(errorMessage: inout String?) -> Bool {
        let isValid = NSPredicate(format: "SELF MATCHES %@", "[a-zA-Z0-9]+").evaluate(with: self)
        if (!isValid) {
            errorMessage = "The secret key is not valid. Please enter a string of uppercase/lowercase letters or numbers."
        }
        return isValid
    }
}

