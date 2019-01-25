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
    func setPendingState(state: LockOutState)
}

class LockOutObserver: NSObject {

    private var state: LockOutState = .Unlocked
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
        state = .Locked
    }
    
    @objc func handleScreenUnlocked() {
        print("Screen is unlocked");
        state = .Unlocked
    }
    
    @objc func timerDidFire() {
        self.isPending = false
        pendingTimer = nil
    }
}

extension LockOutObserver: LockOutDataSource {
    
    func getLockOutState() -> (state: LockOutState, isPending: Bool) {
        return (state, isPending)
    }
    
    func setPendingState(state: LockOutState) {
        self.state = state
        self.pendingTimer?.invalidate()
        self.isPending = true
        pendingTimer = Timer.scheduledTimer(timeInterval: 2,
                                            target: self,
                                            selector: (#selector(timerDidFire)),
                                            userInfo: nil,
                                            repeats: false)
    }
}
