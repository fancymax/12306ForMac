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
    
    fileprivate let autoQuerySecondsKey = "autoQuerySeconds"
    fileprivate let isShowInvalidTicketKey = "isShowInvalidTicket"
    fileprivate let isShowNoTrainTicketKey = "isShowNoTrainTicket"
    fileprivate let isNotifyTicketKey = "isNotifyTicket"
    fileprivate let isNotifyLoginKey = "isNotifyLogin"
    fileprivate let notifyStrKey = "notifyStr"
    fileprivate let notifyLoginStrKey = "notifyLoginStr"
    fileprivate let isAutoQueryAfterFilterKey = "isAutoQueryAfterFilter"
    fileprivate let userDefindStartFilterTimeSpanKey = "userDefindStartFilterTimeSpan"
    fileprivate let userDefindEndFilterTimeSpanKey = "userDefindEndFilterTimeSpan"
    fileprivate let userDefindStartFilterTimeStatusKey = "userDefindStartFilterTimeStatus"
    fileprivate let userDefindEndFilterTimeStatusKey = "userDefindEndFilterTimeStatus"
    
    fileprivate let userDefaults = UserDefaults.standard
    
    fileprivate init()
    {
        registerUserDefault()
    }
    
    fileprivate func registerUserDefault()
    {
        let firstDefault = [autoQuerySecondsKey: 5,
                            isShowInvalidTicketKey: true,
                            isShowNoTrainTicketKey:true,
                            isNotifyTicketKey:true,
                            notifyStrKey:"订到票啦",
                            isNotifyLoginKey:true,
                            notifyLoginStrKey:"要登录啦",
                            isAutoQueryAfterFilterKey:true,
                            userDefindStartFilterTimeSpanKey:["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"],
                            userDefindEndFilterTimeSpanKey:["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"],
                            userDefindStartFilterTimeStatusKey: [true,true,true,true],
                            userDefindEndFilterTimeStatusKey: [true,true,true,true],
                            ]
            as [String : Any]
        userDefaults.register(defaults: firstDefault)
    }
    
    var autoQuerySeconds:Int {
        get{
            return userDefaults.object(forKey: autoQuerySecondsKey) as! Int
        }
        set{
            userDefaults.set(newValue, forKey: autoQuerySecondsKey)
        }
    }
    
    var isShowInvalidTicket:Bool {
        get{
            return userDefaults.object(forKey: isShowInvalidTicketKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isShowInvalidTicketKey)
        }
    }
    
    var isShowNoTrainTicket:Bool {
        get{
            return userDefaults.object(forKey: isShowNoTrainTicketKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isShowNoTrainTicketKey)
        }
    }
    
    var isNotifyTicket:Bool {
        get{
            return userDefaults.object(forKey: isNotifyTicketKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isNotifyTicketKey)
        }
    }
    
    var notifyStr:String {
        get{
            return userDefaults.object(forKey: notifyStrKey) as! String
        }
        set{
            userDefaults.set(newValue, forKey: notifyStrKey)
        }
    }
    
    var isNotifyLogin:Bool {
        get{
            return userDefaults.object(forKey: isNotifyLoginKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isNotifyLoginKey)
        }
    }
    
    var notifyLoginStr:String {
        get{
            return userDefaults.object(forKey: notifyLoginStrKey) as! String
        }
        set{
            userDefaults.set(newValue, forKey: notifyLoginStrKey)
        }
    }
    
    var isAutoQueryAfterFilter:Bool {
        get{
            return userDefaults.object(forKey: isAutoQueryAfterFilterKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isAutoQueryAfterFilterKey)
        }
    }
    
    var userDefindStartFilterTimeSpan:[String] {
        get{
            return userDefaults.array(forKey: userDefindStartFilterTimeSpanKey) as! [String]
        }
        set{
            userDefaults.set(newValue, forKey: userDefindStartFilterTimeSpanKey)
        }
    }
    
    var userDefindEndFilterTimeSpan:[String] {
        get{
            return userDefaults.array(forKey: userDefindEndFilterTimeSpanKey) as! [String]
        }
        set{
            userDefaults.set(newValue, forKey: userDefindEndFilterTimeSpanKey)
        }
    }
    
    var userDefindStartFilterTimeStatus:[Bool] {
        get{
            return userDefaults.array(forKey: userDefindStartFilterTimeStatusKey) as! [Bool]
        }
        set{
            userDefaults.set(newValue, forKey: userDefindStartFilterTimeStatusKey)
        }
    }
    
    var userDefindEndFilterTimeStatus:[Bool] {
        get{
            return userDefaults.array(forKey: userDefindEndFilterTimeStatusKey) as! [Bool]
        }
        set{
            userDefaults.set(newValue, forKey: userDefindEndFilterTimeStatusKey)
        }
    }
    
}
