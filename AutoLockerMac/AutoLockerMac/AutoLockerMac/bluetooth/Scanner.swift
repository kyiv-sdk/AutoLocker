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
    let lastRSSI: NSNumber
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
    private var lockOutDataSource: LockOutDataSource
    private var bleDeviceData: BLEDeviceData
    
    init(lockOutDataSource: LockOutDataSource,
         bleDeviceData: BLEDeviceData) {
        self.bleDeviceData = bleDeviceData
        self.lockOutDataSource = lockOutDataSource;
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
}

extension Scanner: PeripheralScannable
{
    func scanPeripherals() {
        print("start scanning")
        if let identifier = self.bleDeviceData.deviceIdentifier,
            let uuid = UUID(uuidString: identifier) {
            let peripherals = self.centralManager.retrievePeripherals(withIdentifiers: [uuid])
            if (peripherals.count > 0) {
                
            }
        }
        self.centralManager?.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.centralManager!.isScanning {
//                strongSelf.centralManager?.stopScan()
            }
        }
    }
}

extension Scanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            print("state: On")
            scanPeripherals()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            print(name)
        }
        let discoveredPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
        targetPeripheral = discoveredPeripheral
        
    }
}
