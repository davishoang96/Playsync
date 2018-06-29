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
let songs = library.allMediaItems

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
            

            //self.OneWayBackUp(thePlaylists: selected_playlists)

        }
    }
    
    
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the previous selected playlist
        
        
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
                
                
                // Load the previous selected playlist
                for m in selected_playlists{
                    if m == playlist[row].name{
                        if cell.CheckBox.title == m{
                            cell.CheckBox.state = 1
                        }
                    }
                }
                
                
                cell.onClickCheckBox = {sender in

                }
                
                return cell
            }
        }
        return nil
    }
}

