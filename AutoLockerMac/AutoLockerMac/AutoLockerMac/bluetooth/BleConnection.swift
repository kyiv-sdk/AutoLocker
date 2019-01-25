//
//  BleConnection.swift
//  AutoLockerMac
//
//  Created by Borys Zinkovych on 1/25/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleConnection {
    
    private var manager: CBCentralManager
    private var peripheral: DisplayPeripheral
    
    init(manager:CBCentralManager, peripheral:DisplayPeripheral) {
        self.manager = manager
        self.peripheral = peripheral
    }
    
    class func createConnection(central: CBCentralManager,
                                peripheral:DisplayPeripheral) -> BleConnection {
        central.connect(peripheral.peripheral, options: nil)
        return BleConnection(manager: central, peripheral: peripheral)
    }
}

