//
//  ViewController.swift
//  Playsync
//
//  Created by Viet on 28/6/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Cocoa
import iTunesLibrary


//MARK: - Global Var
var library = try! ITLibrary.init(apiVersion: "1.1")
var playlist = library.allPlaylists
let songs = library.allMediaItems

var albums: [String?] = []
var selected_al = [String]()

var artists: [String?] = []

var selected_playlists: [String] = []
var selected_album: [String] = []
var selected_artist: [String] = []


var destinationFolder: String = ""
var destinationFolderURL: URL!

var stop: Bool = false
var data = [Int]()

struct Message {
    var time: String
    var num: Int32
    var filename: String
    var filesize: String
    var birates: UInt
    var datemodified: String
    var message: String
}


var data2 = [Message(time: "", num: 0, filename: "", filesize: "", birates: 0, datemodified: "",  message: "")]


var dataFileC = [String: String]()


class ViewController: NSViewController {
    
    
    //MARK: - Outlet
    @IBOutlet weak var table_playlist: NSTableView!
    @IBOutlet weak var ProgressInfo: NSTextField!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var SyncBtn: NSButton!
    @IBOutlet weak var PathControl: NSPathControl!
    @IBOutlet var consoleTable: NSTableView!
    
    
    
    lazy var sheetViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SheetViewController"))
            as! NSViewController
    }()
    
    
    
    //MARK: - Get destination folder
    @IBAction func onClickPathControl(_ sender: NSPathControl) {
        
        // GUIDE FROM https://stackoverflow.com/questions/29596360/nsopenpanel-as-sheet
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose a destination to sync";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.beginSheetModal(for: self.view.window!, completionHandler: { num in
            if num == NSApplication.ModalResponse.OK {
                let result = dialog.url
                if (result != nil) {
                    
                    self.PathControl.url = result?.absoluteURL
                    destinationFolder = result!.path
                    destinationFolderURL = result!.absoluteURL
                    
                    UserDefaults.standard.setLocation(value: destinationFolder)
                    UserDefaults.standard.setLocationURL(value: destinationFolderURL)
                    
                }
            } else {
                print("nothing chosen")
            }
        })
    }
    
    //MARK: - Sync Button
    @IBAction func onClickSyncBtn(_ sender: NSButton) {

        if SyncBtn.state.rawValue == 1{
            
            print(tools.fileSize(value: selected_playlists))
            
            let queue = OperationQueue()
            
            stop = false
            SyncBtn.title = "Cancel"
            ProgressInfo.isHidden = false
            ProgressBar.doubleValue = 0
            data2.removeAll()
            consoleTable.reloadData()
            
            queue.addOperation {
                self.SyncIt(thePlaylists: selected_playlists, album: selected_album, artist: selected_artist)
            }
            
            
        } else {
            
            if tools.dialogOKCancel(question: "Notice", text: "Do you want to cancel?")
            {
                print(0)
                stop = true
                SyncBtn.title = "Sync"
                SyncBtn.state = NSControl.StateValue(rawValue: 0)
            }
            else
            {
                SyncBtn.state = NSControl.StateValue(rawValue: 1)
            }
        }
    }
    
    
    override func viewWillAppear() {
        
        // OUTLET SETTINGS
        self.ProgressInfo.isHidden = true
        
        
        // LOAD USER SETTING
        let locationURL = UserDefaults.standard.getLocationURL()
        let location = UserDefaults.standard.getLocation()
        
        if locationURL != nil && location != nil
        {
            if tools.checkLocation(value: location) == true
            {
                print("LOCATION FOUND")
            }
            else
            {
                print("LOCATION NOT FOUND")
            }
        }
        
        PathControl.url = locationURL
        destinationFolder = location
        destinationFolderURL = locationURL
        print(destinationFolderURL)
        
    }
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil)
        
    }
    
    
    //MARK: - Reload itunes library after the application has been focus
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        let timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.ReloadLibrary), userInfo: nil, repeats: false)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    //MARK: - Reload library
    @objc func ReloadLibrary()
    {
        do{
            
            library.reloadData()
            playlist = library.allPlaylists
            table_playlist.reloadData()
            
            
            print("LIBRARY RELOADED")
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Sync
    func SyncIt(thePlaylists: [String], album: [String], artist: [String]){
        
        let fileManager = FileManager.default
        let destContent = try! fileManager.contentsOfDirectory(atPath: destinationFolder)
        let removePath = destinationFolder + "/"
        
        
        var SYNCSONG: [String] = []
        var totalsong: Double = 0
        var songleft: Double = 0
        var i: Double = 0
        
        var currentMB: UInt64 = 0
        var num: Int32 = 0
        
        var mediaItems = [ITLibMediaItem]()
        
        mediaItems += tools.getSongFromPlaylist(playlist_name: thePlaylists)!
        mediaItems += tools.getAlbumFromLibrary(album_name: album)!
        mediaItems += tools.getArtistFromLibrary(artist_name: artist)!
        
        
        
        // Get folder content URL to compare files' date modified
        let file = tools.getContentDirectoryAttr(url: destinationFolderURL)
        if file != nil{
            for item in file!{
                let attr = try! FileManager.default.attributesOfItem(atPath: item.path)
                let md = tools.ToCurrentTime(datetime: attr[FileAttributeKey.modificationDate] as! Date)
                dataFileC[item.lastPathComponent] = md
            }
        }
        
        print(dataFileC)
        
        
        if !album.isEmpty
        {
            for i in tools.getAlbumFromLibrary(album_name: album)!
            {
                SYNCSONG.append((i.location?.lastPathComponent)!)
                totalsong += 1
            }
        }
        
        if !artist.isEmpty
        {
            for i in tools.getArtistFromLibrary(artist_name: artist)!
            {
                SYNCSONG.append((i.location?.lastPathComponent)!)
                totalsong += 1
            }
        }
        
        for song in tools.getSongFromPlaylist(playlist_name: selected_playlists)!
        {
            SYNCSONG.append((song.location?.lastPathComponent)!)
            totalsong += 1
        }
        
        print(SYNCSONG)
        
        // Find all songs in folder
        // Delete songs if songs in playlist don't exist in folder
        for item in destContent{
            
            if SYNCSONG.contains(item)
            {
                print(true)
            }
            else {
                print(false)
                print(item)
                try? fileManager.removeItem(atPath: removePath + item)
            }
        }
        
        
        print(totalsong)
        print(songleft)
        
        
        
        for song in mediaItems
        {
            let songpath:String = (song.location?.path)!
            let songfilename = (song.location?.lastPathComponent)!
            let myPath:String = destinationFolder + "/" + songfilename
            
            // Copy songs from selected playlist
            if stop == false{
                do
                {
                    // default copy file without comparision
                    try? fileManager.copyItem(atPath: songpath, toPath: myPath)
                    
                    
                    // copy file with date comparision
                    let songmd = tools.ToCurrentTime(datetime: song.modifiedDate!)
                    if songmd == dataFileC[(song.location?.lastPathComponent)!]
                    {
                        print(true,"-",song.location?.lastPathComponent,"-",tools.ToCurrentTime(datetime: song.modifiedDate!))
                    }
                    else
                    {
                        print(false,"-",song.location?.lastPathComponent,"-",tools.ToCurrentTime(datetime: song.modifiedDate!))
                        if file != nil
                        {
                            for item in file!{
                                
                                if song.location?.lastPathComponent == item.lastPathComponent
                                {
                                    // Remove files at destination
                                    try FileManager.default.removeItem(at: item.absoluteURL)
                                    
                                    // Copy new files to destination
                                    try FileManager.default.copyItem(atPath: songpath, toPath: myPath)
                                }
                            }
                        }
                        else
                        {
                            try? fileManager.copyItem(atPath: songpath, toPath: myPath)
                        }
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
            } else {
                return
            }
            
            currentMB += song.fileSize
            
            
            
            
            print(tools.intToMB(value: currentMB), "of", tools.fileSize(value: selected_playlists))
            print(song.bitrate)
            
            i += 100 / totalsong
            num += 1
            songleft -= 1
            
            DispatchQueue.main.async {
                
                if stop == false {
                    self.ProgressBar.doubleValue = i.rounded()
                    self.ProgressInfo.stringValue = "Copying: " + songfilename
                    
                    data2.append(Message(time: tools.ToCurrentTime(datetime: Date()),
                                         num: num,
                                         filename: songfilename,
                                         filesize: tools.intToMB(value: song.fileSize),
                                         birates: song.bitrate,
                                         datemodified: tools.ToCurrentTime(datetime: song.modifiedDate!),
                                         message: "Copied"))
                    
                    
                    self.consoleTable.reloadData()
                    
                }
                else
                {
                    self.ProgressBar.doubleValue = 0
                    self.ProgressInfo.stringValue = "Stop"
                }
            }
        }
        DispatchQueue.main.async {
            self.SyncBtn.state = NSControl.StateValue(rawValue: 0)
            self.ProgressInfo.stringValue = "Done"
            self.SyncBtn.title = "Sync"
            let dialog = tools.dialogOKCancel(question: "Notice", text: "Sync completed")
        }
    }
}



//MARK: - Table View
extension ViewController: NSTableViewDelegate, NSTableViewDataSource{
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        // Playlist table
        if tableView.tag == 1{
            return playlist.count
        }
            
            // Album table
        else if tableView.tag == 2{
            for item in library.allMediaItems
            {
                if let albumName = item.album.title
                {
                    if !albums.contains(albumName)
                    {
                        albums.append(albumName)
                    }
                }
            }
            return albums.count
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
                        //print(artists)
                    }
                }
            }
            return artists.count
        }
            
        else if tableView.tag == 4{
            if data2.count > 2
            {
                return data2.count
            }
        }
        
        return 0
    }
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Playlist table
        if tableView.tag == 1{
            if (tableColumn?.identifier)!.rawValue == "CheckColumn"{
                if let cell: MyCustomViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckColumn"), owner: self) as? MyCustomViewCell
                {

                    cell.CheckBox.title = playlist[row].name
                    cell.onClickCheckBox = {sender in
                        
                        // Append selected playlist to array if selected
                        if cell.CheckBox.state.rawValue == 1{
                            selected_playlists.append(playlist[row].name)
                        } else {
                            selected_playlists = selected_playlists.filter({ $0 != playlist[row].name })
                        }
                    }
                    
                    return cell
                }
            }
        }
            
            // Album table
        else if tableView.tag == 2{
            if (tableColumn?.identifier)!.rawValue == "AlbumColumn"{
                let cell: MyCustomViewCell = (tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AlbumColumn"), owner: self) as? MyCustomViewCell)!
                
                cell.AlbumCbx.title = albums[row]!
                
                cell.AlbumCbx.state = NSControl.StateValue(rawValue: 0)
                
                for s in selected_album{
                    if cell.AlbumCbx.title == s
                    {
                        print(true, cell.AlbumCbx.title)
                        cell.AlbumCbx.state = NSControl.StateValue(rawValue: 1)
                        
                    }
                }
                
                cell.onClickAlbumCbx = { sender in
                    if cell.AlbumCbx.state.rawValue == 1{
                        selected_album.append(albums[row]!)
                    
                        
                    } else {
                        selected_album = selected_album.filter({ $0 != albums[row]! })
                        
                    }
                }
                
                
                
                return cell
            }
        }
            
        else if tableView.tag == 3
        {
            if (tableColumn?.identifier)!.rawValue == "ArtistColumn"{
                let cell: MyCustomViewCell = (tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ArtistColumn"), owner: self) as? MyCustomViewCell)!
                
                cell.ArtistCbx.title = artists[row]!
                
                cell.ArtistCbx.state = NSControl.StateValue(rawValue: 0)
                
                for s in selected_artist
                {
                    if cell.ArtistCbx.title == s
                    {
                        cell.ArtistCbx.state = NSControl.StateValue(rawValue: 1)
                    }
                }
                
                cell.onClickArtCbx = { sender in
                    if cell.ArtistCbx.state.rawValue == 1{
                        selected_artist.append(artists[row]!)
                        print(row)
                    } else {
                        selected_artist = selected_artist.filter({ $0 != artists[row]! })
                        
                    }
                }
                
                
                return cell
            }
            
        }
            
            // Console table
        else if tableView.tag == 4{
            if (tableColumn?.identifier)!.rawValue == "col_message"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_message"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = data2[row].message
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "col_time"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_time"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = data2[row].time
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "col_filesize"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_filesize"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = String(data2[row].filesize)
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "col_filename"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_filename"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = data2[row].filename
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "col_num"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_num"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = String(data2[row].num)
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "col_birates"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_birates"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = String(data2[row].birates) + " KB"
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "col_datemodified"{
                if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "col_datemodified"), owner: self) as? NSTableCellView
                {
                    cell.textField?.stringValue = String(data2[row].datemodified)
                    return cell
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        if tableView == consoleTable
        {
            if row == consoleTable.numberOfRows - 1
            {
                consoleTable.scrollRowToVisible(row)
            }
        }
    }
}

