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
        
        // Load the previous selected playlist
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
<<<<<<< HEAD
    
    func OneWayBackUp(thePlaylists: [String]){
        
        let fileManager = FileManager.default
        let _playlist = try! ITLibrary.init(apiVersion: "1.1")
        var totalsong: Double = 0
        var i: Double = 0
        
        // Find total song in percentage
        for pls in _playlist.allPlaylists{
            for sync_playlist in thePlaylists {
                if pls.name == sync_playlist{
                    
                    // Find total song
                    
                    let playlist_songs = pls.items.count
                    
                    totalsong += Double(playlist_songs)
                    
                }
            }
        }
        
        print(totalsong)
        
        for pls in _playlist.allPlaylists{
            for sync_playlist in thePlaylists {
                if pls.name == sync_playlist{
                    
                    for song in pls.items{
                        let songpath:String = (song.location?.path)!
                        let songfilename = (song.location?.lastPathComponent)!
                        let myPath:String = destinationFolder + "/" + songfilename
                        print(myPath)
                        // Copy songs from selected playlist
                        try? fileManager.copyItem(atPath: songpath, toPath: myPath)
                        
                        i += 100 / totalsong
                        
                        DispatchQueue.main.async {
                            
    
                            self.ProgressBar.doubleValue = i.rounded()
                   
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
<<<<<<< HEAD
=======
>>>>>>> parent of 70d6bc6... One way backup
=======
>>>>>>> dca096fa03444720eb5e95a3cc549ba0f8fbcf14
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
                
                
                // Load the previous selected playlist
                for m in selected_playlists{
                    if m == playlist[row].name{
                        if cell.CheckBox.title == m{
                            cell.CheckBox.state = 1
                        }
                    }
                }
                
                
                cell.onClickCheckBox = {sender in
                    
                    // Get all song in playlist
                    
<<<<<<< HEAD
                    for song in playlist[row].items{
                        print(song.location?.lastPathComponent)
                    }
                    
                    
=======
>>>>>>> dca096fa03444720eb5e95a3cc549ba0f8fbcf14
                }
                
                return cell
            }
        }
        return nil
    }
}

