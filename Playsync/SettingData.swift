//
//  SettingData.swift
//  Playsync
//
//  Created by Viet on 18/7/18.
//  Copyright © 2018 Viet. All rights reserved.
//

import Foundation
import Cocoa


extension UserDefaults{
    
    
    func setLocation(value: String) {
        set(value, forKey: "destinationFolder")
    }
    
   
    func setLocationURL(value: URL) {
        set(value, forKey: "destinationURL")
    }
    
    func getLocation() -> String{
        return string(forKey: "destinationFolder")!
    }
    
    func getLocationURL() -> URL{
        return url(forKey: "destinationURL")!
    }
    
}

