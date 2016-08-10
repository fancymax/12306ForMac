//
//  AdvancedPrefereceManager.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class AdvancedPreferenceManager {
    
    static let sharedInstance = AdvancedPreferenceManager()
    
    private let isUseDamaKey = "isUseDama"
    private let isUseDamaLoginKey = "isUseDamaLogin"
    private let isStopDamaWhenOperateKey = "isStopDamaWhenOperate"
    private let isStopDamaWhenFail5Key = "isStopDamaWhenFail5"
    
    private let damaUserKey = "damaUser"
    private let damaPasswordKey = "damaPassword"
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private init()
    {
        registerUserDefault()
    }
    
    private func registerUserDefault()
    {
        let firstDefault = [isUseDamaKey: false,isUseDamaLoginKey: true,isStopDamaWhenOperateKey:true,isStopDamaWhenFail5Key: true,damaUserKey:"",damaPasswordKey:""]
        userDefaults.registerDefaults(firstDefault)
    }
    
    var isUseDama:Bool {
        get{
            return userDefaults.objectForKey(isUseDamaKey) as! Bool
        }
        set{
            userDefaults.setObject(newValue, forKey: isUseDamaKey)
        }
    }
    
    var isUseDamaLogin:Bool {
        get{
            return userDefaults.objectForKey(isUseDamaLoginKey) as! Bool
        }
        set{
            userDefaults.setObject(newValue, forKey: isUseDamaLoginKey)
        }
    }
    
    var isStopDamaWhenOperate:Bool {
        get{
            return userDefaults.objectForKey(isStopDamaWhenOperateKey) as! Bool
        }
        set{
            userDefaults.setObject(newValue, forKey: isStopDamaWhenOperateKey)
        }
    }
    
    var isStopDamaWhenFail5:Bool {
        get{
            return userDefaults.objectForKey(isStopDamaWhenFail5Key) as! Bool
        }
        set{
            userDefaults.setObject(newValue, forKey: isStopDamaWhenFail5Key)
            
        }
    }
    
    var damaUser:String {
        get{
            return userDefaults.objectForKey(damaUserKey) as! String
        }
        set{
            userDefaults.setObject(newValue, forKey: damaUserKey)
        }
    }
    
    var damaPassword:String{
        get{
            return userDefaults.objectForKey(damaPasswordKey) as! String
        }
        set{
            userDefaults.setObject(newValue, forKey: damaPasswordKey)
        }
    }
    
}