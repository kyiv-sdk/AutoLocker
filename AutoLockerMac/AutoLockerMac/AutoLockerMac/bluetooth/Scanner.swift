//
//  Scanner.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//


import CoreBluetooth
import Foundation

struct DisplayPeripheral: Hashable {
    let peripheral: CBPeripheral
    let lastRSSI: NSNumber?
    let lastAdvertisementData: [String : Any]?
    
    var hashValue: Int { return peripheral.hashValue }
    
    static func ==(lhs: DisplayPeripheral, rhs: DisplayPeripheral) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
}

protocol ScannerHandler {
    func onPeripheralDiscovered(peripheral:DisplayPeripheral)
    func onPeripheralRetrieved(peripheral:DisplayPeripheral)
    func onBleStateChanged(isPoweredOn: Bool)
}

protocol ConnectionEventsDelegate {
    func onDisconnected(peripheral: CBPeripheral, error: Error?)
    func onConnected(peripheral:CBPeripheral)
    func onFailedToConnect(peripheral: CBPeripheral, error: Error?)
}

class Scanner: NSObject {
    
    private var centralManager: CBCentralManager!
    private var targetPeripheral: DisplayPeripheral?
    private let serviceUUID = CBUUID(string: BLEConstants.kServiceUUID)
    private var lockOutDecider: LockOutDecider
    private var bleDeviceData: BLEDeviceData
    private var connection: BleConnection?
    private var isScanning = false
    
    init(lockOutDecider: LockOutDecider,
         bleDeviceData: BLEDeviceData) {
        self.bleDeviceData = bleDeviceData
        self.lockOutDecider = lockOutDecider;
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    // MARK: Scan logic
    
    func onPeripheralFound(peripheral: DisplayPeripheral) {
        self.targetPeripheral = peripheral
        self.cancelScanning()
        self.connection = BleConnection.createConnection(central: centralManager,
                                                         peripheral: peripheral,
                                                         bleDeviceData: bleDeviceData,
                                                         lockOutDecider: self.lockOutDecider)
    }
    
    func onScanStart() -> Bool {
        if self.centralManager.state != .poweredOn {
            self.isScanning = false
            return false
        }
        if (self.bleDeviceData.getCharacteristicUUID() == nil) {
            print("Scanning is not possible, please set salt");
            return false
        }
        if (self.targetPeripheral != nil ||
            self.isScanning) {
            return false
        }
        // get saved identifier
        if let identifier = self.bleDeviceData.deviceIdentifier,
            let uuid = UUID(uuidString: identifier) {
            let peripherals = self.centralManager.retrievePeripherals(withIdentifiers: [uuid])
            if let peripheral = peripherals.last {
                let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: nil, lastAdvertisementData: nil)
                self.onPeripheralFound(peripheral: displayPeripheral)
                return false
            }
        }
        return true
    }
    
    func isAbleToScan() -> Bool {
        if self.centralManager.state != .poweredOn {
            self.isScanning = false
            return false
        }
        if (self.isScanning) {
            return false
        }
        return true
    }
}

extension Scanner: PeripheralScannable
{
    func scanPeripherals(identifier: UUID?) {
        if onScanStart() == false {
            return
        }
        print("start scanning")
        isScanning = true
        self.centralManager?.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func scanPeripherals() {
        self.scanPeripherals(identifier: nil)
    }
    
    func cancelScanning() {
        if self.isScanning == false {
            return
        }
        self.centralManager?.stopScan()
        self.isScanning = false
    }
}

extension Scanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            print("state: On")
            scanPeripherals()
        }
        else {
            self.isScanning = false;
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if self.isScanning == false {
            return
        }
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            print(name)
        }
        let discoveredPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, lastAdvertisementData: advertisementData)
        self.onPeripheralFound(peripheral: discoveredPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect " + (error?.localizedDescription ?? ""))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral")
        self.connection?.readRSSI()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Did disconnected")
        self.connection?.reconnect()
    }
}
