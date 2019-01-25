//
//  BLEConstants.swift
//  AutoLockerMac
//
//  Created by Borys Zinkovych on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

struct BLEConstants {
    static let kServiceUUID = "DD4C01EF-D7B0-4CF6-9F9D-C29760BD5B9C"
    // characteristic + secret(initial implementation)
    // secret 6 digits at the end
    static let kCharacteristicUUIDPrefix = "3A158467-0CBA-467F-A4AB-DFA167"
    static let kInvalidRSSIMinValue = -15
    static let kMaxRSSIUnlockValue = -50
    static let kMinRSSILockValue = -75
}
