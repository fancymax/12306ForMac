//
//  TicketConstants.swift
//  12306ForMac
//
//  Created by fancymax on 16/9/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

let SEAT_TYPE_ARRAY = ["商务座", "特等座", "一等座", "二等座", "高级软卧", "软卧", "硬卧", "软座", "硬座", "无座"]

//动车
let D_SEAT_TYPE_NAME_DIC = ["商务座": "9", "特等座": "P", "一等座": "M", "二等座": "O","软卧": "F", "无座": "O"]
//普通车
let K_SEAT_TYPE_NAME_DIC = ["高级软卧": "6","软卧": "4", "硬卧": "3", "软座": "2", "硬座": "1", "无座": "1"]

func QuerySeatTypeDicBy(trainCode:String)->[String:String] {
    if (trainCode.containsString("G"))||(trainCode.containsString("D")||(trainCode.containsString("C"))) {
        return D_SEAT_TYPE_NAME_DIC;
    }
    else {
        return K_SEAT_TYPE_NAME_DIC;
    }
}

//20160502->2016-05-02
func Convert2StartTrainDateStr(dateStr: String)->String{
    var formateStr = dateStr
    var index = dateStr.startIndex.advancedBy(4)
    formateStr.insert("-", atIndex: index)
    index = dateStr.startIndex.advancedBy(7)
    formateStr.insert("-", atIndex: index)
    
    return formateStr
}


//let cardTypeNameDic = ["二代身份证": "1", "一代身份证": "2", "港澳通行证": "C", "台湾通行证": "G", "护照": "B"]
//
//let ticketTypeNameDic = ["成人票": "1", "儿童票": "2", "学生票": "3", "残军票": "4"]