//
//  MainModel.swift
//  Train12306
//
//  Created by fancymax on 15/10/6.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

class MainModel{
    static let seatTypeNameDic =
    ["商务座": "9",
        "特等座": "P",
        "一等座": "M",
        "二等座": "O",
        "高级软卧": "6",
        "软卧": "4",
        "硬卧": "3",
        "软座": "2",
        "硬座": "1",
        "无座": "1"]
    
    static let cardTypeNameDic =
    ["二代身份证": "1",
    "一代身份证": "2",
    "港澳通行证": "C",
    "台湾通行证": "G",
    "护照": "B"]
    
    static let ticketTypeNameDic =
    ["成人票": "1",
    "儿童票": "2",
    "学生票": "3",
    "残军票": "4"]
    
    static var realName = ""
    static var isGetUserInfo = false
    
    static var passengers = [PassengerDTO]()
    static var selectPassengers = [PassengerDTO]()
    static var isGetPassengersInfo = false
    
    static var selectedTicket:QueryLeftNewDTO?
    
    static var submitResult: String?
    
    static var orderId:String?
    
    static var globalRepeatSubmitToken:String?
    static var key_check_isChange:String?
    static var train_location:String?
    //"'ypInfoDetail':'O047850026O047853081M059350008'"
    static var ypInfoDetail:String?
    
    static var historyOrderList:[OrderDTOData] = []
    static var noCompleteOrderList:[OrderDTOData] = []
    
    
    static func ticketPriceBy(indentifier:String) -> Double{
        if ypInfoDetail != nil{
            var range = ypInfoDetail!.rangeOfString(indentifier)
            let end = range?.endIndex.advancedBy(5)
            let start = range?.startIndex.advancedBy(1)
            range?.endIndex = end!
            range?.startIndex = start!
            
            let priceStr = ypInfoDetail!.substringWithRange(range!)
            let price = Double(priceStr)! / 10
            Swift.print("indentifier = \(indentifier) price = \(price)")
            return price
        }
        else{
            return 0
        }
    }
    
    static var ticketPrice:Double {
        get{
            var totalPrice:Double = 0
            for passenger in MainModel.selectPassengers{
                totalPrice += ticketPriceBy(passenger.seatCode)
            }
            return totalPrice
            
        }
    }
    
}

