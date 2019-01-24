//
//  Scanner.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

protocol PeripheralScannable: NSObjectProtocol {
    func scanPeripherals()
}
