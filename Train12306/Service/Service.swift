//
//  ServiceBase.swift
//  Train12306
//
//  Created by fancymax on 15/8/4.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation
import AFNetworking
import Alamofire

class Service {
    
    private static var Manager = AFHTTP12306Manager()
    class var shareManager:AFHTTP12306Manager{
        return Service.Manager
    }
    
    static var Manager1 : Alamofire.Manager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = ["kyfw.12306.cn": ServerTrustPolicy.PinCertificates(
                certificates:ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: true)]
        
        // Create custom manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let man = Alamofire.Manager(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return man
    }()

    
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