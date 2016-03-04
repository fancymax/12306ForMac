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
    
    static var Manager : Alamofire.Manager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = ["kyfw.12306.cn": ServerTrustPolicy.PinCertificates(
                certificates:ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: true)]
        
        // Create custom manager
        let headers = [
            "refer": "https://kyfw.12306.cn/otn/leftTicket/init",
            "Host": "kyfw.12306.cn",
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:36.0) Gecko/20100101 Firefox/36.0",
            "Connection" : "keep-alive"
        ]
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers
        let manager = Alamofire.Manager(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()

    func requestDynamicJs(jsName:String,referHeader:[String:String])->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/dynamicJs/" + jsName
            Service.Manager
                .request(.GET, url, headers:referHeader)
                .response(completionHandler:{
                    _ in fulfill()
            })
        }
    }
    
}