//
//  LockOutManager.swift
//  AutoLockerMac
//
//  Created by Borys Zinkovych on 1/25/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

enum LockStrategy {
    case LockStrategyRSSIReading
    case LockStrategyUnlock
    case LockStrategyLock
}

protocol LockOutDecider {
    func getLockStrategy(rssi: NSNumber) -> LockStrategy
}

class LockOutManager {
    var lockOutObserver: LockOutObserver = LockOutObserver()
}

extension LockOutManager: LockOutDecider {
    
    // Mark: Lock/Unlock login
    // TODO: move into a dedicated class
    func getLockStrategy(rssi: NSNumber) -> LockStrategy {
        if rssi.intValue > BLEConstants.kInvalidRSSIMinValue {
            return .LockStrategyRSSIReading
        }
        if rssi.intValue < BLEConstants.kMinRSSILockValue {
            if lockOutObserver.getLockOutState() == .Unlocked {
                return .LockStrategyLock
            }
        }
        if rssi.intValue < BLEConstants.kMinRSSILockValue {
            if lockOutObserver.getLockOutState() == .Unlocked {
                return .LockStrategyLock
            }
        }
        return .LockStrategyRSSIReading
    }
}
