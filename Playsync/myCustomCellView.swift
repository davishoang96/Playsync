//
//  myCustomCellView.swift
//  Playsync
//
//  Created by Viet on 29/6/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Cocoa

class myCustomCellView: NSTableCellView {

    //Playlist checkbox
    var onClickPlaylistCbx: ((_ sender: NSButton) -> ())?
    @IBOutlet weak var PlaylistCbx: NSButton!
    @IBAction func onClickPlaylistCbx(_ sender: NSButton) {
        onClickPlaylistCbx?(sender)
    }
    
    //Album checkbox
    var onClickAlbumCbx: ((_ sender: NSButton) -> ())?
    @IBOutlet weak var AlbumCbx: NSButton!
    @IBAction func onClickAlbumCbx(_ sender: NSButton) {
        onClickAlbumCbx?(sender)
    }
    
    
    //Artist checkbox
    var onClickArtistCbx: ((_ sender: NSButton) -> ())?
    @IBOutlet weak var ArtistsCbx: NSButton!
    @IBAction func onClickArtistCbx(_ sender: NSButton) {
        onClickArtistCbx?(sender)
    }
    
    
    
}
