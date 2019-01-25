//
//  BleConnection.swift
//  AutoLockerMac
//
//  Created by Borys Zinkovych on 1/25/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BleConnectionProtocol {
    func didConnect()
    func didFailToConnect()
}

class BleConnection: NSObject {
    
    private var manager: CBCentralManager
    private var peripheral: DisplayPeripheral
    private var lockOutManager: LockOutDecider
    private let serviceUUID = CBUUID(string: BLEConstants.kServiceUUID)

    init(manager:CBCentralManager,
         peripheral:DisplayPeripheral,
         lockOutDecider: LockOutDecider) {
        self.manager = manager
        self.peripheral = peripheral
        self.lockOutManager = lockOutDecider
        super.init()
        // setup
        peripheral.peripheral.delegate = self
    }
    
    class func createConnection(central: CBCentralManager,
                                peripheral:DisplayPeripheral,
                                lockOutDecider: LockOutDecider) -> BleConnection {
        central.connect(peripheral.peripheral, options: nil)
        return BleConnection(manager: central,
                             peripheral: peripheral,
                             lockOutDecider: lockOutDecider)
    }
}

extension BleConnection: BleConnectionProtocol
{
    func didConnect() {
        print("connection established for peripheral " + (peripheral.peripheral.name ?? "unnamed"))
        self.peripheral.peripheral.readRSSI()
    }
    
    func didFailToConnect() {
        print("connection failed for peripheral " + (peripheral.peripheral.name ?? "unnamed"))
    }
}

extension BleConnection: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // if rssi is invalid
        // or rssi is not defined for lock/unlock
        // then keep on reading
        switch self.lockOutManager.getLockStrategy(rssi: RSSI) {
        case .LockStrategyRSSIReading:
            print("keep on reading RSSI")
            peripheral.readRSSI()
        case .LockStrategyUnlock:
            print("Try to unlock mac: current step is service discovering")
            peripheral.discoverServices([self.serviceUUID])
        case .LockStrategyLock:
            print("Try to lock mac")
            // TODO:
            peripheral.readRSSI()
        }
    }
}
