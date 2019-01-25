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
        
        //toggleLaunchAtStartup()
        
        lock()
        
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
        let appleScript = NSAppleScript(source: "do shell script \"/System/Library/CoreServices/'Menu Extras'/User.menu/Contents/Resources/CGSession -suspend\"")
        
        appleScript?.executeAndReturnError(nil);
    }
}
