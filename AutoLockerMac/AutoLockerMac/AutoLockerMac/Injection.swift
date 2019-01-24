//
//  File.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

class Injection {
    private let scanner = Scanner(lockOutDataSource: LockOutObserver())
    
    static let shared = Injection()
    
    private init() {
        
    }
    
     func injectBleScanner() -> PeripheralScannable {
        return scanner;
    }
    
    
}
