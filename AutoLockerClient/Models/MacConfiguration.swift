//
//  MacConfiguration.swift
//  AutoLockerClient
//
//  Created by Borys Zinkovych on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import Foundation

struct MacConfiguration {
    let password: String
    let secret: String
    
    init(password: String, secret: String) {
        self.password = password
        self.secret = secret
    }
}
