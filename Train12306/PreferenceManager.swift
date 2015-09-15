//
//  PreferenceManager.swift
//  Train12306
//
//  Created by fancymax on 15/8/14.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class PreferenceManager {
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var users :[User]?{
        get{
            return userDefaults.objectForKey(userNameKey) as? [User]
        }
    }
    
    private let userNameKey = "users"
}
