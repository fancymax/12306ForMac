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
        if let reloginStr = isRelogin , reloginStr == "Y" {
            return true;
        }
        else {
            return false;
        }
    }
    
    func isTicketSoldOut() -> Bool {
        if let status = op_2 , status == "true" {
            return true;
        }
        else {
            return false;
        }
    }
    
    func getWarningInfoBy(_ seatCodeName:String) -> String {
        var warningStr = ""
        if let leftTicket = ticket {
            if leftTicket.contains(",") {
                let nums = leftTicket.components(separatedBy: ",")
                assert(nums.count == 2)
                warningStr += "本次列车 剩余\(seatCodeName) \(nums[0]) 张, 无座 \(nums[1])张"
            }
            else {
                warningStr += "本次列车 剩余\(seatCodeName) \(leftTicket) 张"
            }
        }
        if let status = op_2 , status == "true" {
            warningStr += ",目前排队人数已经超过余票张数，请您选择其他席别或车次"
        }
        else {
            if let queueNum = countT , queueNum != "0" {
                warningStr += ",目前排队人数 \(queueNum)"
            }
        }
        return warningStr
    }
    
    
}
