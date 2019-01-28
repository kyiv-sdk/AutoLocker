//
//  LockOutObserver.swift
//  AutoLockerMac
//
//  Created by Borys Zinkovych on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

enum LockOutState {
    case Locked
    case Unlocked
}

protocol LockOutDataSource {
    func getLockOutState() -> (state: LockOutState, isPending: Bool)
    func setPendingState()
}

class LockOutObserver: NSObject {

    private var state: LockOutState = .Unlocked
    private var lastStateBeforePending: LockOutState = .Unlocked
    private var pendingTimer: Timer?
    private var isPending = false
    
    override init() {
        super.init()
        let center = DistributedNotificationCenter.default()
        center.addObserver(self, selector: #selector(handleScreenLocked), name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"), object: nil)
        center.addObserver(self, selector: #selector(handleScreenUnlocked), name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
    }
    
    @objc func handleScreenLocked() {
       print("Screen is locked");
        self.isPending = false
        self.pendingTimer?.invalidate()
        pendingTimer = nil
        state = .Locked
    }
    
    @objc func handleScreenUnlocked() {
        print("Screen is unlocked");
        self.isPending = false
        self.pendingTimer?.invalidate()
        pendingTimer = nil
        state = .Unlocked
    }
    
    @objc func timerDidFire() {
        self.isPending = false
        self.pendingTimer?.invalidate()
        pendingTimer = nil
        if lastStateBeforePending == state {
            // TODO: maybe show error message? 
            print("Error!!! state was not changed after script execution, current state \(state)")
        }
    }
    
    func resetTimer() {
        self.pendingTimer?.invalidate()
        self.pendingTimer = nil
    }
}

extension LockOutObserver: LockOutDataSource {
    
    func getLockOutState() -> (state: LockOutState, isPending: Bool) {
        let isPendingState = self.isPending
        return (state, isPendingState)
    }
    
    func setPendingState() {
        print("Pending state" + (state == .Locked ? "Locked":"Unlocked"));
        self.pendingTimer?.invalidate()
        self.isPending = true
        self.lastStateBeforePending = self.state
        pendingTimer = Timer.scheduledTimer(timeInterval: 3,
                                            target: self,
                                            selector: (#selector(timerDidFire)),
                                            userInfo: nil,
                                            repeats: false)
    }
}
