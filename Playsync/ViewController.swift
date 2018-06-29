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
var playlist = library.allPlaylists
var songs = library.allMediaItems
var album: [String?] = []
var artists: [String?] = []


var selected_playlists: [String] = []
var destinationFolder: String = ""


class ViewController: NSViewController {
    
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    
    @IBOutlet weak var ChooseFolderBtn: NSButton!
    @IBOutlet weak var SyncBtn: NSButton!
    
    
    
    
    @IBAction func onClickChooseBtn(_ sender: NSButton) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a destination to sync";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
    
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                destinationFolder = result!.path
                //AlertMessage.messageBox(message: "Alert", info: destinationFolder)
                print(destinationFolder)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func onClickSyncBtn(_ sender: NSButton) {
        
        ProgressBar.doubleValue = 0
        
        DispatchQueue.global(qos:.background).async {
            

            self.OneWayBackUp(thePlaylists: selected_playlists)

        }
    }
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
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
}




extension ViewController: NSTableViewDelegate, NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
       
        
        
        if tableView.tag == 1{
            return playlist.count
        }
        else if tableView.tag == 2
        {
            for item in library.allMediaItems
            {
                if let albumName = item.album.title
                {
                    if !album.contains(albumName)
                    {
                        album.append(albumName)
                    }
                }
            }
            return album.count
        }
        else if tableView.tag == 3
        {
            for item in library.allMediaItems
            {
                if let artistName = item.artist?.name
                {
                    if !artists.contains(artistName)
                    {
                        artists.append(artistName)
                    }
                }
            }
            
            return artists.count
            
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.tag == 1{
            if tableColumn?.identifier == "CheckColumn"{
                if let cell: myCustomCellView = tableView.make(withIdentifier: "CheckColumn", owner: self) as? myCustomCellView
                {
                    cell.PlaylistCbx.state = 0
                    cell.PlaylistCbx.title = playlist[row].name
                    cell.onClickPlaylistCbx = {sender in
                        
                        // Append selected playlist to array
                        print(cell.PlaylistCbx.title)
                        selected_playlists.append(playlist[row].name)

                    }
                    return cell
                }
            }
        }
        else if tableView.tag == 2{
            if tableColumn?.identifier == "AlbumColumn"{
                if let cell: myCustomCellView = tableView.make(withIdentifier: "AlbumColumn", owner: self) as? myCustomCellView
                {
                    cell.AlbumCbx.state = 0
                    
                    cell.AlbumCbx.title = album[row]!
                    
                    cell.onClickAlbumCbx = {sender in
                        
                        print(cell.AlbumCbx.title)
                        
                    }
                    
                    return cell
                }
            }
        }
        else if tableView.tag == 3{
            if tableColumn?.identifier == "ArtistColumn"{
                if let cell: myCustomCellView = tableView.make(withIdentifier: "ArtistColumn", owner: self) as? myCustomCellView
                {
                    cell.ArtistsCbx.state = 0
                    
                    cell.ArtistsCbx.title = artists[row]!
                    
                    cell.onClickArtistCbx = {sender in
                        
                        print(cell.ArtistsCbx.title)
                    }
                    
                    return cell
                }
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
}

