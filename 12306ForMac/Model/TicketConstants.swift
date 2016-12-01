//
//  TicketConstants.swift
//  12306ForMac
//
//  Created by fancymax on 16/9/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

//let cardTypeNameDic = ["二代身份证": "1", "一代身份证": "2", "港澳通行证": "C", "台湾通行证": "G", "护照": "B"]

let SEAT_TYPE_ARRAY = ["商务座", "特等座", "一等座", "二等座", "高级软卧", "软卧", "硬卧", "软座", "硬座", "无座"]

//动车
let D_SEAT_TYPE_NAME_DIC = ["商务座": "9", "特等座": "P", "一等座": "M", "二等座": "O","软卧": "F", "无座": "O"]

let D_SEAT_TYPE_KEYPATH_DIC = ["商务座": "Swz_Num", "特等座": "Tz_Num", "一等座": "Zy_Num", "二等座": "Ze_Num","软卧": "Rw_Num", "无座": "Wz_Num"]

//普通车
let K_SEAT_TYPE_NAME_DIC = ["高级软卧": "6","软卧": "4", "硬卧": "3", "软座": "2", "硬座": "1", "无座": "1"]
let K_SEAT_TYPE_KEYPATH_DIC = ["高级软卧": "Gr_Num","软卧": "Rw_Num", "硬卧": "Yw_Num", "软座": "Rz_Num", "硬座": "Yw_Num", "无座": "Wz_Num"]

func G_QuerySeatTypeNameDicBy(_ trainCode:String)->[String:String] {
    if (trainCode.contains("G"))||(trainCode.contains("D")||(trainCode.contains("C"))) {
        return D_SEAT_TYPE_NAME_DIC;
    }
    else {
        return K_SEAT_TYPE_NAME_DIC;
    }
}

func G_QuerySeatTypeKeyPathDicBy(_ trainCode:String)->[String:String] {
    if (trainCode.contains("G"))||(trainCode.contains("D")||(trainCode.contains("C"))) {
        return D_SEAT_TYPE_KEYPATH_DIC;
    }
    else {
        return K_SEAT_TYPE_KEYPATH_DIC;
    }
}

//20160502->2016-05-02
func G_Convert2StartTrainDateStr(_ dateStr: String)->String{
    var formateStr = dateStr
    var index = dateStr.characters.index(dateStr.startIndex, offsetBy: 4)
    formateStr.insert("-", at: index)
    index = dateStr.characters.index(dateStr.startIndex, offsetBy: 7)
    formateStr.insert("-", at: index)
    
    return formateStr
}

