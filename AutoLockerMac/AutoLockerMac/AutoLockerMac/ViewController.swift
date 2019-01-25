//
//  ViewController.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    
    let presenter = Presenter(scanner: Injection.shared.injectBleScanner())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggleLaunchAtStartup()
        
        presenter.attachView(view: self)
        presenter.startScanPeripherals()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}


extension ViewController: View {
   
    func lock() {
        let path = Bundle.main.path(forResource: "lockScreen", ofType: "scpt")
        let url = URL(fileURLWithPath: path ?? "")
        
        var errors: NSDictionary?
    
        let appleScript = NSAppleScript(contentsOf: url, error: &errors)

        if let script = appleScript {
            var possibleError: NSDictionary?
            script.executeAndReturnError(&possibleError)
            if let error = possibleError {
                print("ERROR: \(error)")
            }
        }
    }
}
