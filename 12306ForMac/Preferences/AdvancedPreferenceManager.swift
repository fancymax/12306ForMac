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
    
    fileprivate let isUseDamaKey = "isUseDama"
    fileprivate let isUseDamaLoginKey = "isUseDamaLogin"
    fileprivate let isStopDamaWhenOperateKey = "isStopDamaWhenOperate"
    fileprivate let isStopDamaWhenFail5Key = "isStopDamaWhenFail5"
    
    fileprivate let damaUserKey = "damaUser"
    fileprivate let damaPasswordKey = "damaPassword"
    
    fileprivate let userDefaults = UserDefaults.standard
    fileprivate init()
    {
        registerUserDefault()
    }
    
    fileprivate func registerUserDefault()
    {
        let firstDefault = [isUseDamaKey: false,isUseDamaLoginKey: true,isStopDamaWhenOperateKey:true,isStopDamaWhenFail5Key: true,damaUserKey:"",damaPasswordKey:""] as [String : Any]
        userDefaults.register(defaults: firstDefault)
    }
    
    var isUseDama:Bool {
        get{
            return userDefaults.object(forKey: isUseDamaKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isUseDamaKey)
        }
    }
    
    var isUseDamaLogin:Bool {
        get{
            return userDefaults.object(forKey: isUseDamaLoginKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isUseDamaLoginKey)
        }
    }
    
    var isStopDamaWhenOperate:Bool {
        get{
            return userDefaults.object(forKey: isStopDamaWhenOperateKey) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isStopDamaWhenOperateKey)
        }
    }
    
    var isStopDamaWhenFail5:Bool {
        get{
            return userDefaults.object(forKey: isStopDamaWhenFail5Key) as! Bool
        }
        set{
            userDefaults.set(newValue, forKey: isStopDamaWhenFail5Key)
            
        }
    }
    
    var damaUser:String {
        get{
            return userDefaults.object(forKey: damaUserKey) as! String
        }
        set{
            userDefaults.set(newValue, forKey: damaUserKey)
        }
    }
    
    var damaPassword:String{
        get{
            return userDefaults.object(forKey: damaPasswordKey) as! String
        }
        set{
            userDefaults.set(newValue, forKey: damaPasswordKey)
        }
    }
    
}
