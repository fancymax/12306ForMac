//
//  AFHTTP12306Manager.swift
//  Train12306
//
//  Created by fancymax on 15/11/24.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation
import AFNetworking

class AFHTTP12306Manager:AFHTTPRequestOperationManager
{
    init(){
        super.init(baseURL:nil)
        //OS X 10.11 ATS
        //Check srca.cer
        self.securityPolicy = AFSecurityPolicy(pinningMode: .Certificate)
        self.securityPolicy.allowInvalidCertificates = true
        var certificates = [NSData]()
        let bundle = NSBundle.mainBundle()
        let paths = bundle.pathsForResourcesOfType("cer", inDirectory: ".")
        for path in paths {
            let certificateData = NSData(contentsOfFile: path)
            certificates.append(certificateData!)
        }
        self.securityPolicy.pinnedCertificates = certificates
        
        self.requestSerializer.HTTPShouldHandleCookies = true
        self.requestSerializer.setValue("kyfw.12306.cn", forHTTPHeaderField:"Host")
        self.requestSerializer.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:36.0) Gecko/20100101 Firefox/36.0", forHTTPHeaderField:"User-Agent")
        self.requestSerializer.setValue("keep-alive", forHTTPHeaderField:"Connection")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func OperationForGET(URLString: String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) -> AFHTTPRequestOperation? {
        let request = self.requestSerializer.requestWithMethod("GET", URLString: URLString, parameters: parameters,error: nil)
        return self.HTTPRequestOperationWithRequest(request, success: success, failure: failure)
    }
    
    func OperationForPOST(URLString: String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) -> AFHTTPRequestOperation? {
        let request = self.requestSerializer.requestWithMethod("POST", URLString: URLString, parameters: parameters,error: nil)
        return self.HTTPRequestOperationWithRequest(request, success: success, failure: failure)
    }
}