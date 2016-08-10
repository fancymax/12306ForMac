//
//  GeneralPreferenceManager.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class GeneralPreferenceManager {
    
    static let sharedInstance = GeneralPreferenceManager()
    
    private let autoQuerySecondsKey = "autoQuerySeconds"
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private init()
    {
        registerUserDefault()
    }
    
    private func registerUserDefault()
    {
        let firstDefault = [autoQuerySecondsKey: 5]
        userDefaults.registerDefaults(firstDefault)
    }
    
    var autoQuerySeconds:Int {
        get{
            return userDefaults.objectForKey(autoQuerySecondsKey) as! Int
        }
        set{
            userDefaults.setObject(newValue, forKey: autoQuerySecondsKey)
        }
    }
}
