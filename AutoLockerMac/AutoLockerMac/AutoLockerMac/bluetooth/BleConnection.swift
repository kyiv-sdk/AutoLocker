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
    private var bleDeviceData: BLEDeviceData
    var characteristicUUID: CBUUID;

    init(manager:CBCentralManager,
         peripheral:DisplayPeripheral,
         bleDeviceData: BLEDeviceData,
         lockOutDecider: LockOutDecider) {
        self.manager = manager
        self.peripheral = peripheral
        self.lockOutManager = lockOutDecider
        self.characteristicUUID = CBUUID(string: bleDeviceData.getCharacteristicUUID()!)
        self.bleDeviceData = bleDeviceData
        super.init()
        // setup
        peripheral.peripheral.delegate = self
        self.manager.connect(peripheral.peripheral, options: nil)
    }
    
    class func createConnection(central: CBCentralManager,
                                peripheral:DisplayPeripheral,
                                bleDeviceData: BLEDeviceData,
                                lockOutDecider: LockOutDecider) -> BleConnection {
        return BleConnection(manager: central,
                             peripheral: peripheral,
                             bleDeviceData: bleDeviceData,
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
        if let error = error {
            print("peripheral didreadRSSI error:" + error.localizedDescription)
            peripheral.readRSSI()
            return
        }
        print("peripheral didReadRSSI")
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
            self.lockOutManager.handleLock()
            peripheral.readRSSI()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("peripheral didDiscoverServices error:" + error.localizedDescription)
            return
        }
        print("peripheral didDiscoverServices")
        var targetService: CBService? = nil
        guard let services = peripheral.services else {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("ERROR!: no services")
            return
        }
        for service in services {
            if service.uuid == self.serviceUUID {
                targetService = service
                break
            }
        }
        guard let targetDiscoveredService = targetService else {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("ERROR!: no services with target UUID")
            return
        }
        peripheral.discoverCharacteristics([characteristicUUID], for: targetDiscoveredService)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("peripheral didDiscoverCharacteristics error:" + error.localizedDescription)
            return
        }
        print("peripheral didDiscoverCharacteristics")
        var targetCharacteristic: CBCharacteristic? = nil
        guard let characteristics = service.characteristics else {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("ERROR!: no services")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == self.characteristicUUID {
                targetCharacteristic = characteristic
                break
            }
        }
        guard let targetDiscoveredCharacteristic = targetCharacteristic else {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("ERROR!: no characteristics with target UUID")
            return
        }
        peripheral.readValue(for: targetDiscoveredCharacteristic)
        peripheral.setNotifyValue(true, for: targetDiscoveredCharacteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            //TODO:handle error properly, maybe close connection and scan for peripherals again?
            print("peripheral didUpdateValueForCharacteristic error:" + error.localizedDescription)
            return
        }
        let data = characteristic.value
        self.lockOutManager.handleUnlock(data: data)
    }
    
}
