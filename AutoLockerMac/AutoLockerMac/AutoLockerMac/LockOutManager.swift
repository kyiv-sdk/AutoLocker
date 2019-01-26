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

var isLocaked:Bool = false

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
//        if isLocaked == false {
//            isLocaked = true
//            return .LockStrategyLock
//        }
        return .LockStrategyRSSIReading
    }
    
    func handleLock() {
        print("handle lock")
        self.lockOutObserver.setPendingState(state: .Locked)
//        let appleScript = NSAppleScript(source: "do shell script \"/System/Library/CoreServices/'Menu Extras'/User.menu/Contents/Resources/CGSession -suspend\"")
        let script = "activate application \"SystemUIServer\" \n"+"tell application \"System Events\"\n" + "tell process \"SystemUIServer\" to keystroke \"q\" using {command down, control down}\n"+"end tell"
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil);
    }
    
    func handleUnlock(data: Data?) {
        print("handle unlock")
        self.lockOutObserver.setPendingState(state: .Unlocked)

        guard let receivedData = data else {
            //TODO:handle error
            return
        }
        let password = String(decoding: receivedData, as: UTF8.self)
        self.lockOutObserver.setPendingState(state: .Unlocked)
        let appleScript = NSAppleScript(source: "tell application \"System Events\"\n"+"keystroke \""+password+"\"\n"+"key code 36\n"+"end tell")
        
        appleScript?.executeAndReturnError(nil);
        
//        let appleScript = NSAppleScript(source: "tell application \"System Events\"\n"+"keystroke \"user\"\n"+"key code 36\n"+"end tell")
//
//        appleScript?.executeAndReturnError(nil);
    }
}
