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
    private let ifShowInvalidTicketKey = "ifShowInvalidTicket"
    private let ifShowNoTrainTicketKey = "ifShowNoTrainTicket"
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private init()
    {
        registerUserDefault()
    }
    
    private func registerUserDefault()
    {
        let firstDefault = [autoQuerySecondsKey: 5,ifShowInvalidTicketKey: true, ifShowNoTrainTicketKey:true]
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
    
    var ifShowInvalidTicket:Bool {
        get{
            return userDefaults.objectForKey(ifShowInvalidTicketKey) as! Bool
        }
        set{
            userDefaults.setObject(newValue, forKey: ifShowInvalidTicketKey)
        }
    }
    
    var ifShowNoTrainTicket:Bool {
        get{
            return userDefaults.objectForKey(ifShowNoTrainTicketKey) as! Bool
        }
        set{
            userDefaults.setObject(newValue, forKey: ifShowNoTrainTicketKey)
        }
    }
    
}
