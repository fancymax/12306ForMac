//
//  ServiceBase.swift
//  Train12306
//
//  Created by fancymax on 15/8/4.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class Service {
    private static var Manager = AFHTTP12306Manager()
    class var shareManager:AFHTTP12306Manager{
        return Service.Manager
    }
    
    func removeSession(){
        Service.Manager = AFHTTP12306Manager()
    }
    
    func setRefer(refer:String)
    {
        Service.shareManager.requestSerializer.setValue(refer, forHTTPHeaderField:"refer")
    }
    
    func setReferLeftTicketInit(){
        setRefer("https://kyfw.12306.cn/otn/leftTicket/init")
    }
    
    func setReferLoginInit(){
        setRefer("https://kyfw.12306.cn/otn/login/init")
    }
    
    func setReferInitDC(){
        setRefer("https://kyfw.12306.cn/otn/confirmPassenger/initDc")
    }
    
    func setReferInitMy12306(){
        setRefer("https://kyfw.12306.cn/otn/index/initMy12306")
    }
    
    func setReferQueryOrderInit(){
        setRefer("https://kyfw.12306.cn/otn/queryOrder/init")
    }
}