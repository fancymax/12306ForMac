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
    
    fileprivate let userNameKey = "userName"
    fileprivate let userPasswordKey = "userPassword"
    fileprivate let fromStationKey = "fromStation"
    fileprivate let toStationKey = "toStation"
    fileprivate let queryDateKey = "queryDate"
    fileprivate let userDefaults = UserDefaults.standard
    
    fileprivate init()
    {
        registerUserDefault()
    }
    
    fileprivate func registerUserDefault()
    {
        let firstDefault = [fromStationKey: "深圳",
            toStationKey:"上海",queryDateKey:LunarCalendarView.getMostAvailableDay()] as [String : Any]
        userDefaults.register(defaults: firstDefault)
    }
    
    var lastUserName:String?{
        get{
            return userDefaults.object(forKey: userNameKey) as? String
        }
        set(newValue){
            userDefaults.set(newValue, forKey: userNameKey)
        }
    }
    
    var lastUserPassword:String?{
        get{
            return userDefaults.object(forKey: userPasswordKey) as? String
        }
        set(newValue){
            userDefaults.set(newValue, forKey: userPasswordKey)
        }
    }
    
    var lastFromStation:String{
        get{
            return userDefaults.object(forKey: fromStationKey) as! String
        }
        set(newValue){
            userDefaults.set(newValue, forKey: fromStationKey)
        }
    }
    
    var lastToStation:String{
        get{
            return userDefaults.object(forKey: toStationKey) as! String
        }
        set(newValue){
            userDefaults.set(newValue, forKey: toStationKey)
        }
    }
    
    var lastQueryDate:Date{
        get{
            return userDefaults.object(forKey: queryDateKey) as! Date
        }
        set(newValue){
            userDefaults.set(newValue, forKey: queryDateKey)
        }
    }
}
