//
//  AppDelegate.swift
//  Playsync
//
//  Created by Viet on 28/6/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var preferencesController: NSWindowController!

    @IBAction func onClickMenuPref(_ sender: Any) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "PreferenceWindows"), bundle: nil)
        if let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Settings")) as? NSWindowController
        {
            windowController.showWindow(self)
        }
  
        
        
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = sender.windows.first {
            if flag {
                window.orderFront(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                
            }
        }
        
        return true
    }
    
    

}

