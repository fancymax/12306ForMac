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
        case CheckUserFailed       = -7005
        case SubmitOrderFailed     = -7006
        case CheckOrderInfoFailed  = -7007
        case ConfirmSingleForQueueFailed  = -7008
    }
    
    public static func errorWithCode(code:Code)->NSError{
        var failureReason = ""
        switch code {
            case .LoginFailed:
                failureReason = "登录失败"
            
            case .QueryTicketFailed:
                failureReason = "未能查到任何车次,请检查查询设置"
            
            case .SumbitFailed:
                failureReason = "提交订单失败"
            
            case .GetRandCodeFailed:
                failureReason = "获取验证码失败"
            
            case .CheckRandCodeFailed:
                failureReason = "验证码错误"
            
            case .CheckUserFailed:
                failureReason = "非登录状态，需要重新登录"
            
            case .SubmitOrderFailed:
                failureReason = "提交订单失败"
            
            case .CheckOrderInfoFailed:
                failureReason = "订单信息错误"
            
            case .ConfirmSingleForQueueFailed:
                failureReason = "锁定订单失败"
        }
        return errorWithCode(code, failureReason: failureReason)
    }

    public static func errorWithCode(code: Code, failureReason: String) -> NSError {
        return errorWithCode(code.rawValue, failureReason: failureReason)
    }

    public static func errorWithCode(code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
    
}