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
    func handleUnlock(data: Data?)
    func handleLock()
}

class LockOutManager {
    var lockOutObserver: LockOutObserver = LockOutObserver()
}

extension LockOutManager: LockOutDecider {
    
    func getLockStrategy(rssi: NSNumber) -> LockStrategy {
        let absValue = abs(rssi.intValue)
        let lockOutResponse = lockOutObserver.getLockOutState()
        if rssi.intValue > BLEConstants.kInvalidRSSIMinValue ||
            lockOutResponse.isPending == true {
            return .LockStrategyRSSIReading
        }
        if absValue > abs(BLEConstants.kMinRSSILockValue) {
            if lockOutResponse.state == .Unlocked {
                return .LockStrategyLock
            }
        }
        if absValue < abs(BLEConstants.kMaxRSSIUnlockValue) {
            if lockOutResponse.state == .Locked {
                return .LockStrategyUnlock
            }
        }
        return .LockStrategyRSSIReading
    }
    
    func handleLock() {
        print("handle lock")
        self.lockOutObserver.setPendingState(state: .Locked)
        let appleScript = NSAppleScript(source: "do shell script \"/System/Library/CoreServices/'Menu Extras'/User.menu/Contents/Resources/CGSession -suspend\"")
        
        appleScript?.executeAndReturnError(nil);
    }
    
    func handleUnlock(data: Data?) {
        print("handle unlock")
        self.lockOutObserver.setPendingState(state: .Unlocked)
        let appleScript = NSAppleScript(source: "tell application \"System Events\" to keystroke \"Boris0210z\"")
        
        appleScript?.executeAndReturnError(nil);
    }
}
