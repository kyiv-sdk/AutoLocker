//
//  File.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

class Injection {
    private let bleDeviceData: BLEDeviceData
    private let scanner: Scanner
    private let lockOutDecider: LockOutDecider
    static let shared = Injection()
    
    private init() {
        let bleDeviceData = BLEDeviceData.restoreFromStorage()
        let lockOutDecider = LockOutManager()
        self.bleDeviceData = bleDeviceData
        self.scanner = Scanner(lockOutDecider:lockOutDecider,
                bleDeviceData: bleDeviceData)
        self.lockOutDecider = lockOutDecider
    }
    
    func injectBleScanner() -> PeripheralScannable {
        return scanner;
    }
    
    func injectBleDeviceData() -> BLEDeviceData {
        return bleDeviceData
    }
}
