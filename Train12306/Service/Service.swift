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
        //OS X 10.11 ATS
        //Check srca.cer
        Service.Manager.securityPolicy = AFSecurityPolicy(pinningMode: .Certificate)
        Service.Manager.securityPolicy.allowInvalidCertificates = true
        Service.Manager.requestSerializer.HTTPShouldHandleCookies = true
        Service.Manager.requestSerializer.setValue("kyfw.12306.cn", forHTTPHeaderField:"Host")
        Service.Manager.requestSerializer.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:36.0) Gecko/20100101 Firefox/36.0", forHTTPHeaderField:"User-Agent")
        Service.Manager.requestSerializer.setValue("keep-alive", forHTTPHeaderField:"Connection")
        
        
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
}