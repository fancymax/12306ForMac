//
//  ServiceError.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

func translate(error:NSError)->String{
    
    if error.domain == "NSURLErrorDomain"{
        if error.code == -1009 {
            return "网络连接失败，请检查连接或稍后再试"
        }
    }
    if let err = error.localizedFailureReason{
        return err
    }
    else{
        return error.localizedDescription
    }
}

struct ServiceError {
    static let Domain = "com.12306Service.error"

    enum Code: Int {
        case LoginFailed           = -7000
        case QueryTicketFailed     = -7001
        case SumbitFailed          = -7002
        case GetRandCodeFailed     = -7003
        case CheckRandCodeFailed   = -7004
        case CheckUserFailed       = -7005
        case SubmitOrderFailed     = -7006
        case CheckOrderInfoFailed  = -7007
        case ConfirmSingleForQueueFailed  = -7008
        case CancelOrderFailed = -7009
    }
    
    static let errorDic = [
        Code.LoginFailed:"登录失败",
        Code.QueryTicketFailed:"未能查到任何车次,请检查查询设置",
        Code.SumbitFailed: "提交订单失败",
        Code.GetRandCodeFailed: "获取验证码失败",
        Code.CheckRandCodeFailed: "验证码错误",
        Code.CheckUserFailed: "非登录状态，需要重新登录",
        Code.SubmitOrderFailed: "提交订单失败",
        Code.CheckOrderInfoFailed: "订单信息错误",
        Code.ConfirmSingleForQueueFailed: "锁定订单失败",
        Code.CancelOrderFailed: "取消订单失败"]
    
    static func errorWithCode(code:Code)->NSError{
        if errorDic.keys.contains(code) {
            return errorWithCode(code, failureReason: errorDic[code]!)
        }
        else {
            return errorWithCode(code, failureReason: "未知错误, 错误码 = \(code.rawValue)")
        }
    }

    static func errorWithCode(code: Code, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code.rawValue, userInfo: userInfo)
    }
    
}