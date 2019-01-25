//
//  String+AppName.swift
//  AutoLockerClient
//
//  Created by ysirko on 1/25/19.
//  Copyright © 2019 sss. All rights reserved.
//

import Foundation

extension String {
    
    static var appName: String {
        get { return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "" }
    }
    
}

