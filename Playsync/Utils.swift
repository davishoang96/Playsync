//
//  Utils.swift
//  Playsync
//
//  Created by Viet on 18/7/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Foundation
import Cocoa
import iTunesLibrary

class tools{
    
    class func checkLocation(value: String) -> Bool
    {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: value, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    class func getContentDirectoryAttr(url: URL) -> [URL]!
    {
        let fileManager = FileManager.default
        let content = try! fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        
        if content.count > 0{
            return content
        }
        return nil
    }
    
    class func getLibraryLocation() -> URL?
    {
        do{
            let library = try ITLibrary.init(apiVersion: "1.1")
            return library.mediaFolderLocation!
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    class func getSongFromPlaylist(playlist_name: [String]) -> [ITLibMediaItem]?
    {
        do
        {
            let library = try ITLibrary.init(apiVersion: "1.1")
            let playlist = library.allPlaylists
            var item = [ITLibMediaItem]()
            for pls in playlist
            {
                for pl in playlist_name
                {
                    if pls.name == pl
                    {
                        for songs in pls.items
                        {
                            item.append(songs)
                        }
                    }
                }
            }
            return item
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    class func getAlbumFromLibrary(album_name: [String]) -> [ITLibMediaItem]?
    {
        do
        {
            let library = try ITLibrary.init(apiVersion: "1.1")
            let allMediaItems = library.allMediaItems
            var item = [ITLibMediaItem]()
            
            for an in album_name
            {
                for mediaItems in allMediaItems
                {
                    if mediaItems.album.title == an
                    {
                        item.append(mediaItems)
                    }
                }
            }
            
            return item
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    class func getArtistFromLibrary(artist_name: [String]) -> [ITLibMediaItem]?
    {
        do
        {
            let library = try ITLibrary.init(apiVersion: "1.1")
            let allMediaItems = library.allMediaItems
            var item = [ITLibMediaItem]()
            
            for artname in artist_name
            {
                for mediaItems in allMediaItems
                {
                    if mediaItems.artist?.name == artname
                    {
                        item.append(mediaItems)
                    }      
                }
            }
            return item
            
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
       
    }
    
    class func compareFileDate(url: URL) -> Bool
    {
        do {
            
            let fileManager = FileManager.default
 
            let attr = try fileManager.attributesOfItem(atPath: url.path)
  
            let content = try fileManager.contentsOfDirectory(at: destinationFolderURL, includingPropertiesForKeys: nil)

            for c in content
            {
                let a: Date = attr[FileAttributeKey.modificationDate] as! Date
                let attr2 = try fileManager.attributesOfItem(atPath: c.absoluteURL.path)
                let b: Date = attr2[FileAttributeKey.modificationDate] as! Date
                
                print("-",ToCurrentTime(datetime: a))
                print("-",ToCurrentTime(datetime: b))
                print(c.lastPathComponent)
                
                if ToCurrentTime(datetime: a) == ToCurrentTime(datetime: b)
                {
                    return true
                } else
                {
                    return false
                }
            }
            
        } catch
        {
            print(error)
            return false
        }
        return false
    }
    
    class func ToCurrentTime(datetime: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateTimeInIsoFormatForZuluTimeZone: String = dateFormatter.string(from: datetime)
        return dateTimeInIsoFormatForZuluTimeZone
    }
    
    class func intToMB(value: UInt64) -> String
    {
        // GUIDE FROM https://stackoverflow.com/questions/42722498/print-the-size-megabytes-of-data-in-swift-3-0/42722744
        
        let byteCount = value // replace with data.count
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let result = bcf.string(fromByteCount: Int64(byteCount))
        return result
    }
    
    class func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    class func fileSize(value: [String]) -> String
    {
        var totalsize: UInt64 = 0
        var result: String = ""
        
        let playlists = try! ITLibrary.init(apiVersion: "1.1").allPlaylists
        for playlist in playlists
        {
            for pls in value
            {
                if playlist.name == pls
                {
                    for song in playlist.items
                    {
                        totalsize += song.fileSize
                    }
                }
            }
        }
        
        result = intToMB(value: totalsize)
        
        return result
        
    }
}
