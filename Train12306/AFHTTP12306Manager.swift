//
//  AFHTTP12306Manager.swift
//  Train12306
//
//  Created by fancymax on 15/11/24.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

class AFHTTP12306Manager:AFHTTPRequestOperationManager
{
    func OperationForGET(URLString: String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) -> AFHTTPRequestOperation? {
        let request = self.requestSerializer.requestWithMethod("GET", URLString: URLString, parameters: parameters,error: nil)
        return self.HTTPRequestOperationWithRequest(request, success: success, failure: failure)
    }
    
    func OperationForPOST(URLString: String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) -> AFHTTPRequestOperation? {
        let request = self.requestSerializer.requestWithMethod("POST", URLString: URLString, parameters: parameters,error: nil)
        return self.HTTPRequestOperationWithRequest(request, success: success, failure: failure)
    }
}