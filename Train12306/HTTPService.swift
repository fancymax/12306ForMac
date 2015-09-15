//
//  ServiceBase.swift
//  Train12306
//
//  Created by fancymax on 15/8/4.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class HTTPService {
    
    static let staticHTTPManager = AFHTTPRequestOperationManager()
    
    static var token = ""
    
    
    var shareHTTPManager:AFHTTPRequestOperationManager{
        get{
            HTTPService.staticHTTPManager.securityPolicy.allowInvalidCertificates = true
            return HTTPService.staticHTTPManager
        }
    }
}