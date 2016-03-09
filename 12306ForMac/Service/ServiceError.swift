//
//  ServiceError.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

public struct ServiceError {
    public static let Domain = "com.12306Service.error"

    public enum Code: Int {
        case LoginFailed           = -7000
        case QueryTicketFailed     = -7001
        case SumbitFailed          = -7002
        case GetRandCodeFailed     = -7003
        case CheckRandCodeFailed   = -7004
    }

    public static func errorWithCode(code: Code, failureReason: String) -> NSError {
        return errorWithCode(code.rawValue, failureReason: failureReason)
    }

    public static func errorWithCode(code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
    
}