//
//  OrderQueueDTO.swift
//  Train12306
//
//  Created by fancymax on 16/3/3.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class TicketQueueCountResult{
    var count:String?
    var countT:String?
    var op_2:String?
    var op_1:String?
    var ticket:String?
    var isRelogin:String?
    
    
    init(json:JSON)
    {
        count = json["count"].string
        countT = json["countT"].string
        op_1 = json["op_1"].string
        op_2 = json["op_2"].string
        ticket = json["ticket"].string
        isRelogin = json["isRelogin"].string
    }
    
    func shouldRelogin()->Bool {
        if let reloginStr = isRelogin where reloginStr == "Y" {
            return true;
        }
        else {
            return false;
        }
    }
    
    func isTicketSoldOut() -> Bool {
        if let status = op_2 where status == "true" {
            return true;
        }
        else {
            return false;
        }
    }
    
    func getWarningInfoBy(seatCodeName:String,trainCode:String) -> String {
        var warningStr = ""
        if let yp_info = ticket {
            let seatInfos = getSeatInfosFrom(yp_info: yp_info, trainCode: trainCode)
            if let seatTypePair = seatInfos[seatCodeName] {
                warningStr += "本次列车 剩余\(seatCodeName) \(seatTypePair.number) 张"
            }
        }
        if let status = op_2 where status == "true" {
            warningStr += ",目前排队人数已经超过余票张数，请您选择其他席别或车次"
        }
        else {
            if let queueNum = countT where queueNum != "0" {
                warningStr += ",目前排队人数 \(queueNum)"
            }
        }
        return warningStr
    }
    
    
}
