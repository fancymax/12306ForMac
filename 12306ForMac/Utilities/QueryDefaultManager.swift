//
//  UserDefaultManager.swift
//  Train12306
//
//  Created by fancymax on 15/11/26.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

class QueryDefaultManager {
    static let sharedInstance = QueryDefaultManager()
    
    private let userNameKey = "userName"
    private let userPasswordKey = "userPassword"
    private let fromStationKey = "fromStation"
    private let toStationKey = "toStation"
    private let queryDateKey = "queryDate"
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private init()
    {
        registerUserDefault()
    }
    
    private func registerUserDefault()
    {
        let firstDefault = [fromStationKey: "深圳",
            toStationKey:"上海",queryDateKey:NSDate()]
        userDefaults.registerDefaults(firstDefault)
    }
    
    var lastUserName:String?{
        get{
            return userDefaults.objectForKey(userNameKey) as? String
        }
        set(newValue){
            userDefaults.setObject(newValue, forKey: userNameKey)
        }
    }
    
    var lastUserPassword:String?{
        get{
            return userDefaults.objectForKey(userPasswordKey) as? String
        }
        set(newValue){
            userDefaults.setObject(newValue, forKey: userPasswordKey)
        }
    }
    
    var lastFromStation:String?{
        get{
            return userDefaults.objectForKey(fromStationKey) as? String
        }
        set(newValue){
            userDefaults.setObject(newValue, forKey: fromStationKey)
        }
    }
    
    var lastToStation:String?{
        get{
            return userDefaults.objectForKey(toStationKey) as? String
        }
        set(newValue){
            userDefaults.setObject(newValue, forKey: toStationKey)
        }
    }
    
    var lastQueryDate:NSDate?{
        get{
            return userDefaults.objectForKey(queryDateKey) as? NSDate
        }
        set(newValue){
            userDefaults.setObject(newValue, forKey: queryDateKey)
        }
    }
}