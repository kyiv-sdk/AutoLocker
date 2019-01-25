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
    let isConnectable: Bool
    
    var hashValue: Int { return peripheral.hashValue }
    
    static func ==(lhs: DisplayPeripheral, rhs: DisplayPeripheral) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
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
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive))
    }
    
    // MARK: Scan logic
    
    func onPeripheralFound(peripheral: DisplayPeripheral) {
        self.targetPeripheral = peripheral
        // TODO:
        self.isScanning = false
        self.connection = BleConnection.createConnection(central: self.centralManager,
                                                         peripheral: peripheral,
                                                         bleDeviceData: bleDeviceData, 
                                                         lockOutDecider: self.lockOutDecider)
        self.cancelScanning()
    }
    
    func onScanStart() -> Bool {
        if self.centralManager.state != .poweredOn {
            print("can not scan, scanner is off")
            self.isScanning = false;
            //TODO:
//            self.cancelScanning()
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
                let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: nil, isConnectable: true)
                self.onPeripheralFound(peripheral: displayPeripheral)
                return false
            }
        }
        return true
    }
}

extension Scanner: PeripheralScannable
{
    func scanPeripherals() {
        if onScanStart() == false {
            return
        }
        print("start scanning")
        isScanning = true
        self.centralManager?.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        // TODO: remove later
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
//            guard let strongSelf = self else { return }
//            if strongSelf.centralManager!.isScanning {
//                strongSelf.centralManager?.stopScan()
//            }
//        }
    }
    
    func cancelScanning() {
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
            print("state: Of")
            cancelScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if self.isScanning == false{
            return
        }
        let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as! Bool
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if name == "AutoLock advertisement" {
                print("Catch avertisement")
                return;
            }
            print(name)
        }
        let discoveredPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
        self.onPeripheralFound(peripheral: discoveredPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.connection?.didFailToConnect()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connection?.didConnect()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
}
