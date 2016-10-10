//
//  ServiceError.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct ServiceError {
    static let Domain = "com.12306Service.error"

    enum Code: Int {
        case loginFailed           = -7000
        case queryTicketFailed     = -7001
        case sumbitFailed          = -7002
        case getRandCodeFailed     = -7003
        case checkRandCodeFailed   = -7004
        case checkUserFailed       = -7005
        case submitOrderFailed     = -7006
        case checkOrderInfoFailed  = -7007
        case confirmSingleForQueueFailed  = -7008
    }
    
    static let errorDic = [
        Code.loginFailed:"登录失败",
        Code.queryTicketFailed:"未能查到任何车次,请检查查询设置",
        Code.sumbitFailed: "提交订单失败",
        Code.getRandCodeFailed: "获取验证码失败",
        Code.checkRandCodeFailed: "验证码错误",
        Code.checkUserFailed: "非登录状态，需要重新登录",
        Code.submitOrderFailed: "提交订单失败",
        Code.checkOrderInfoFailed: "订单信息错误",
        Code.confirmSingleForQueueFailed: "锁定订单失败"]
    
    static func errorWithCode(_ code:Code)->NSError{
        if errorDic.keys.contains(code) {
            return errorWithCode(code, failureReason: errorDic[code]!)
        }
        else {
            return errorWithCode(code, failureReason: "未知错误, 错误码 = \(code.rawValue)")
        }
    }

    static func errorWithCode(_ code: Code, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code.rawValue, userInfo: userInfo)
    }
    
}
