//
//  ViewController.swift
//  Playsync
//
//  Created by Viet on 28/6/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Cocoa
import iTunesLibrary

let library = try! ITLibrary.init(apiVersion: "1.1")
let playlist = library.allPlaylists

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == "CheckColumn"{
            if let cell: MyCustomViewCell = tableView.make(withIdentifier: "CheckColumn", owner: self) as? MyCustomViewCell
            {
                cell.CheckBox.setNextState()
                cell.CheckBox.title = playlist[row].name
                cell.onClickCheckBox = {sender in
                    
                    // Get all song in playlist
                    
                    for song in playlist[row].items{
                        print(song.location?.lastPathComponent)
                    }
                    
                    
                    
                    
                }
                return cell
            }
        }
        return nil
    }
}

