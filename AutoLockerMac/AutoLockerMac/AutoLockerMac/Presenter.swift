//
//  Presenter.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Foundation

class Presenter {
    
    private weak var view: View?
    private weak var scanner: PeripheralScannable?
    
    init(scanner: PeripheralScannable) {
        self.scanner = scanner
    }
    
    func attachView(view: View) {
        self.view = view
    }
    
    func startScanPeripherals() {
        scanner?.scanPeripherals()
    }
}
