//
//  MyCustomViewCell.swift
//  Playsync
//
//  Created by Viet on 28/6/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Cocoa

class MyCustomViewCell: NSTableCellView {

    // Playlist checkbox
    var onClickCheckBox: ((_ sender: NSButton) -> ())?
    @IBOutlet weak var CheckBox: NSButton!
    @IBAction func onClickCheckBox(_ sender: NSButton) {
        onClickCheckBox?(sender)
    }
    
    //Album checkbox
    
    
    
    
}
