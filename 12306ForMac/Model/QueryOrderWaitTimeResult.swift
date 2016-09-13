//
//  QueryOrderWaitTimeResult.swift
//  Train12306
//
//  Created by fancymax on 16/3/3.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class QueryOrderWaitTimeResult{
    var queryOrderWaitTimeStatus: Bool?
    var count:Int?
    var waitTime:Int?
//    var requestId:
    var waitCount:Int?
    var tourFlag:String?
    var orderId:String?
    var msg:String?
    
    init(json:JSON)
    {
        queryOrderWaitTimeStatus = json["queryOrderWaitTimeStatus"].boolValue
        count = json["count"].intValue
        waitTime = json["waitTime"].intValue
        waitCount = json["waitCount"].intValue
        tourFlag = json["tourFlag"].string
        orderId = json["orderId"].string
        msg = json["msg"].string
    }
}