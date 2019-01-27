//
//  BleManager.swift
//  AutoLockerMac
//
//  Created by User on 27.01.2019.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

import CoreBluetooth

// TODO: remove optionals,
// enable blemanager

class BleManager: NSObject {
    private let scanner: Scanner? = nil
    private var connection: BleConnection? = nil
    private var bleDeviceData: BLEDeviceData? = nil
    private var centralManager: CBCentralManager!
    private var lockOutDecider: LockOutDecider!
    override init() {
        super.init()
        self.startManaging()
    }
    
    func startManaging() {
        if (self.bleDeviceData!.getCharacteristicUUID() == nil) {
            //TODO: handle on application layer
            print("Scanning is not possible, please set salt");
            return
        }
        if self.connection != nil {
            return
        }
        var uuid: UUID? = nil
        if let identifier = self.bleDeviceData!.deviceIdentifier {
             uuid = UUID(uuidString: identifier)
        }
        self.scanner?.scanPeripherals(identifier: uuid)
    }
    
    func startConnection(peripheral:DisplayPeripheral) {
        self.scanner!.cancelScanning()
        self.connection = BleConnection.createConnection(central: centralManager,
                                                         peripheral: peripheral,
                                                         bleDeviceData: bleDeviceData!,
                                                         lockOutDecider: self.lockOutDecider)
    }
}

extension BleManager: ScannerHandler {
    
    func onPeripheralDiscovered(peripheral:DisplayPeripheral) {
        guard let advData = peripheral.lastAdvertisementData,
            let name = advData[CBAdvertisementDataLocalNameKey] as? String else {
            return
        }
        print("Discovered" + name)
        // TODO: name verification to secret value
        self.startConnection(peripheral: peripheral)
    }
    
    func onPeripheralRetrieved(peripheral:DisplayPeripheral) {
        self.startConnection(peripheral: peripheral)
    }
    
    func onBleStateChanged(isPoweredOn: Bool) {
        if isPoweredOn {
            self.startManaging()
        }
        // TODO: need to close connection here?
    }
}

extension BleManager: ConnectionEventsDelegate {
    
    func onDisconnected(peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func onConnected(peripheral:CBPeripheral) {
        
    }
    
    func onFailedToConnect(peripheral: CBPeripheral, error: Error?) {
        
    }
}

extension BleManager: BleConnectionHandler {
    
    func onReadingFailed(error: Error) {
        
    }
    
    func onReadData(data: NSData) {
        
    }
    
    func onRSSIReceived(rssi: NSNumber) {
        switch self.lockOutManager.getLockStrategy(rssi: rssi) {
        case .LockStrategyRSSIReading:
            print("keep on reading RSSI")
            self.connection!.readRSSI()
        case .LockStrategyUnlock:
            print("Try to unlock mac: current step is service discovering")
            peripheral.discoverServices([self.serviceUUID])
        case .LockStrategyLock:
            print("Try to lock mac")
            self.lockOutDecider!.handleLock()
            self.connection!.readRSSI()
        }
    }
}
