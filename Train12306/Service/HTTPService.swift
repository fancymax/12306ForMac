//
//  ServiceBase.swift
//  Train12306
//
//  Created by fancymax on 15/8/4.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class HTTPService {
    
    internal static var staticHTTPManager = AFHTTP12306Manager()
    
    var shareHTTPManager:AFHTTP12306Manager{
        get{
            //OS X 10.11
//            <key>NSAppTransportSecurity</key>
//            <dict>
//            <key>NSExceptionDomains</key>
//            <dict>
//            <key>YOURHOST.COM</key>
//            <dict>
//            <key>NSIncludesSubdomains</key>
//            <true/>
//            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
//            <true/>
//            <key>NSTemporaryExceptionMinimumTLSVersion</key>
//            <string>1.0</string>
//            <key>NSTemporaryExceptionRequiresForwardSecrecy</key>
//            <false/>
//            </dict>
//            </dict>
//            </dict>
            
            //todo  此处应该保证仅执行一次
            HTTPService.staticHTTPManager.securityPolicy = AFSecurityPolicy(pinningMode: .None)
            HTTPService.staticHTTPManager.securityPolicy.validatesDomainName = false
            HTTPService.staticHTTPManager.securityPolicy.allowInvalidCertificates = true
            HTTPService.staticHTTPManager.requestSerializer.HTTPShouldHandleCookies = true
            
            HTTPService.staticHTTPManager.requestSerializer.setValue("kyfw.12306.cn", forHTTPHeaderField:"Host")
            HTTPService.staticHTTPManager.requestSerializer.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:36.0) Gecko/20100101 Firefox/36.0", forHTTPHeaderField:"User-Agent")
            HTTPService.staticHTTPManager.requestSerializer.setValue("keep-alive", forHTTPHeaderField:"Connection")
            
            
            return HTTPService.staticHTTPManager
        }
    }
    
    func removeSession(){
        HTTPService.staticHTTPManager = AFHTTP12306Manager()
    }
    
    func setRefer(refer:String)
    {
        shareHTTPManager.requestSerializer.setValue(refer, forHTTPHeaderField:"refer")
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