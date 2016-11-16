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
        let serverTrustPolicies: [String: ServerTrustPolicy] = ["kyfw.12306.cn": ServerTrustPolicy.pinCertificates(
                certificates:ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true)]
        
        // Create custom manager
        let headers = [
            "refer": "https://kyfw.12306.cn/otn/leftTicket/init",
            "Host": "kyfw.12306.cn",
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:36.0) Gecko/20100101 Firefox/36.0",
            "Connection" : "keep-alive"]
        let configuration = URLSessionConfiguration.default
        
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpAdditionalHeaders = headers
        configuration.timeoutIntervalForRequest = 5
        
        let manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()

    func requestDynamicJs(_ jsName:String,referHeader:[String:String])->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/dynamicJs/" + jsName
            Service.Manager.request(url, headers:referHeader).response(completionHandler:{ _ in
                fulfill()
            })
        }
    }
    
}
