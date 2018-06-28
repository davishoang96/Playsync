//
//  AlertMessage.swift
//  Playsync
//
//  Created by Viet on 28/6/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Foundation
import Cocoa

class AlertMessage
{
    class func messageBox(message: String, info: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = info
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let result = alert.runModal()
       
    }
}
