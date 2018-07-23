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
    var onClickAlbumCbx: ((_ sender: NSButton) -> ())?
    @IBOutlet weak var AlbumCbx: NSButton!
    @IBAction func onClickAlbumCbx(_ sender: NSButton) {
        onClickAlbumCbx?(sender)
    }
    
    
    var onClickArtCbx: ((_ sender: NSButton) -> ())?
    @IBOutlet var ArtistCbx: NSButton!
    @IBAction func onClickArtCbx(_ sender: NSButton) {
        onClickArtCbx?(sender)
    }
    
    
    
}
