//
//  ViewController.swift
//  AutoLockerMac
//
//  Created by Andrzej Mistetskij on 1/24/19.
//  Copyright © 2019 Andrzej Mistetskij. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    private var alert: NSAlert?
    let presenter = Presenter(scanner: Injection.shared.injectBleScanner())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //toggleLaunchAtStartup()

        
        presenter.startScanPeripherals()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if Injection.shared.injectLockOutManager().isAccessibillityAllowed() == false {
            showAccessibillityAlert()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func showAccessibillityAlert() {
        let alert = NSAlert()
        self.alert = alert
        alert.messageText = "Allow accessibillity"
        let button = alert.addButton(withTitle: "Open preferences")
        button.action = #selector(handleShowAccessibillityPreference)
        button.target = self
        alert.runModal()
    }
    
    @objc func handleShowAccessibillityPreference() {
        //        tell application "System Preferences"
        //        activate
        //        set the current pane to pane id "com.apple.preference.security"
        //        reveal anchor "Privacy_Accessibility" of pane id "com.apple.preference.security"
        //        end tell
        let appleScript = NSAppleScript(source: "tell application \"System Preferences\"\n"+"activate\n"+"set the current pane to pane id \"com.apple.preference.security\"\n"+"reveal anchor \"Privacy_Accessibility\" of pane id \"com.apple.preference.security\"\n"+"end tell")
        
        var dict: NSDictionary? = nil
        appleScript?.executeAndReturnError(&dict);
        
        // TODO: dismiss an alert 
    }
}



