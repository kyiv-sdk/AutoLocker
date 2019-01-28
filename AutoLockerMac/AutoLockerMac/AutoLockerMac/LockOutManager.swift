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
    func isAccessibillityAllowed() ->Bool
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
        return .LockStrategyRSSIReading
    }
    
    func handleLock() {
        print("handle lock")
        self.lockOutObserver.setPendingState()
//        let appleScript = NSAppleScript(source: "do shell script \"/System/Library/CoreServices/'Menu Extras'/User.menu/Contents/Resources/CGSession -suspend\"")
//        let script = "activate application \"SystemUIServer\" \n"+"tell application \"System Events\"\n" + "tell process \"SystemUIServer\" to keystroke \"q\" using {command down, control down}\n"+"end tell"
                let script = "tell application \"System Events\" to keystroke \"q\" using {command down, control down}"
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil);
    }
    
    func handleUnlock(data: Data?) {
        print("handle unlock")

        if self.lockOutObserver.getLockOutState().isPending {
            return
        }
        
        guard let receivedData = data else {
            //TODO:handle error
            return
        }
        let password = String(decoding: receivedData, as: UTF8.self)
        print("Password" + password)
        self.lockOutObserver.setPendingState()
        let appleScript = NSAppleScript(source: "tell application \"System Events\"\n"+"keystroke \""+password+"\"\n"+"key code 36\n"+"end tell\n" + "do shell script \"caffeinate -u -t 2\"")
        
        var dict: NSDictionary? = nil
        appleScript?.executeAndReturnError(&dict);
    }
    
    func isAccessibillityAllowed() -> Bool{
 
        let appleScript = NSAppleScript(source: "tell application \"System Events\"\n"+"keystroke \" \"\n"+"key code 36\n"+"end tell\n")
        
        var dict: NSDictionary? = nil
        appleScript?.executeAndReturnError(&dict);
        if let dict = dict,
            let _ = dict["NSAppleScriptErrorNumber"] {
            return false;
        }
        return true
    }
}
