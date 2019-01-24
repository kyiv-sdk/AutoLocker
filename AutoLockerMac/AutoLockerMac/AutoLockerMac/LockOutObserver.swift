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
    func getLockOutState() -> LockOutState
}

class LockOutObserver: NSObject {

    private var state: LockOutState = .Unlocked
    
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
}

extension LockOutObserver: LockOutDataSource {
    func getLockOutState() -> LockOutState {
        return state
    }
}
