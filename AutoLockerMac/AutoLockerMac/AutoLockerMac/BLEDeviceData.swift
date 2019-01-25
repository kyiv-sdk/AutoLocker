//
//  BLEDeviceDataHolder.swift
//  AutoLockerMac
//
//  Created by Borys Zinkovych on 1/25/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

class BLEDeviceData: Codable
{
    static private let kStorageKey = "SavedDeviceData"
    
    var salt: String? {
        didSet {
            saveToStorage()
        }
    }
    var deviceIdentifier: String? {
        didSet {
            saveToStorage()
        }
    }
    
    func saveToStorage() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: BLEDeviceData.kStorageKey)
        }
    }
    
    class func restoreFromStorage() -> BLEDeviceData {
        if let savedData = UserDefaults.standard.object(forKey: kStorageKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedBLEInfoObject = try? decoder.decode(BLEDeviceData.self, from: savedData) {
                return loadedBLEInfoObject
            }
        }
        return BLEDeviceData()
    }
}
