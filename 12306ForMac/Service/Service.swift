//
//  ServiceBase.swift
//  Train12306
//
//  Created by fancymax on 15/8/4.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class Service {
    
    static let sharedInstance = Service()
    
    private init(){ }
    
    static var Manager : Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = ["kyfw.12306.cn": ServerTrustPolicy.performDefaultEvaluation(validateHost: true)]

        // Create custom manager
        let headers = [
            "refer": "https://kyfw.12306.cn/otn/leftTicket/init",
            "Host": "kyfw.12306.cn",
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:36.0) Gecko/20100101 Firefox/36.0",
            "Connection" : "keep-alive"]
        let configuration = URLSessionConfiguration.default
        
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpAdditionalHeaders = headers
        configuration.timeoutIntervalForRequest = 10
        
        let manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    @objc var passport_appId = "otn"
    @objc var passport_login = "https://kyfw.12306.cn/passport/web/login"
    @objc var passport_captcha = "https://kyfw.12306.cn/passport/captcha/captcha-image"
    @objc var passport_authuam = "https://kyfw.12306.cn/passport/web/auth/uamtk"
    @objc var passport_captcha_check = "https://kyfw.12306.cn/passport/captcha/captcha-check"
    @objc var passport_authclient = "uamauthclient"
    @objc var passport_loginPage = "login/init"
    @objc var passport_okPage = "index/initMy12306"
    
    func getConfigFromInitContent(_ content:String) {
        func getMatchByKey(_ key:String, matchVar:inout String) {
            if let matches = Regex("var \(key) = '([^']+)'").getMatches(content){
                matchVar = matches[0][0]
            }
            else{
                logger.error("fail to get \(key)")
            }
        }
        
        getMatchByKey(#keyPath(passport_appId),matchVar: &passport_appId)
        getMatchByKey(#keyPath(passport_login),matchVar: &passport_login)
        getMatchByKey(#keyPath(passport_captcha),matchVar: &passport_captcha)
        getMatchByKey(#keyPath(passport_authuam),matchVar: &passport_authuam)
        getMatchByKey(#keyPath(passport_captcha_check),matchVar: &passport_captcha_check)
        getMatchByKey(#keyPath(passport_authclient),matchVar: &passport_authclient)
    }
    
    func jc_getcookie(key:String) -> String? {
       return nil
    }
    
    let referKey = "refer"
    let referValueForLoginInit = "https://kyfw.12306.cn/otn/login/init"

    func requestDynamicJs(_ jsName:String,referHeader:[String:String])->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/dynamicJs/" + jsName
            Service.Manager.request(url, headers:referHeader).response(completionHandler:{ _ in
                fulfill()
            })
        }
    }
    
}
