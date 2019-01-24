//
//  BLEManager.swift
//  AutoLockerClient
//
//  Created by Borys Zinkovych on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import Foundation

protocol BLEDataDelegate {
    func getPeripheralCharacteristic() -> Data?
    func getPeripheralUUID() -> String?
}

class BLEManager: NSObject, BLEDataDelegate {
    
    private var macConfiguration: MacConfiguration?
    private var peripheralManager: PeripheralController?
    
    static let sharedInstance = BLEManager()

    private override init() {
        super.init()
        // TODO: restoreConfiguration
        setupPeripheralController()
    }
    
    public func addConfiguration(macConfiguration: MacConfiguration) {
        self.macConfiguration = macConfiguration
        setupPeripheralController()
    }
    
    func setupPeripheralController() {
        if (self.macConfiguration != nil) {
            self.peripheralManager = PeripheralController(bleDataDelegate: self)
            self.peripheralManager!.start()
        }
    }
    
    func getPeripheralCharacteristic() -> Data? {
        guard let password = self.macConfiguration?.password else {
            // TODO:enable assert later assert(false, "")
            return nil
        }
        let result = password.data(using: String.Encoding.utf8)!
        return result
    }
    
    func getPeripheralUUID() -> String? {
        guard let secret = self.macConfiguration?.secret else {
            // TODO:enable assert later assert(false, "")
            return nil
        }
        let uuid = BLEConstants.kCharacteristicUUIDPrefix + secret
        return uuid
    }
}

