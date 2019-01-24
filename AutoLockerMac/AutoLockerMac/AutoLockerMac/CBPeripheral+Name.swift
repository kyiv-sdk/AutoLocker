//
//  CBPeripheral+Name.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
    var displayName: String {
        guard let name = name, !name.isEmpty else { return "No Device Name" }
        return name
    }
}
