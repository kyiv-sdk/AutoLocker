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
    
    static let shared = Injection()
    
    private init() {
        let bleDeviceData = BLEDeviceData.restoreFromStorage()
        self.bleDeviceData = bleDeviceData
        self.scanner = Scanner(lockOutDataSource: LockOutObserver(),
                bleDeviceData: bleDeviceData)
    }
    
    func injectBleScanner() -> PeripheralScannable {
        return scanner;
    }
    
    func injectBleDeviceData() -> BLEDeviceData {
        return bleDeviceData
    }
}
