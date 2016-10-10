//
//  MainModel.swift
//  Train12306
//
//  Created by fancymax on 15/10/6.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

class MainModel{
    static var realName = ""
    static var userName = ""
    static var isGetUserInfo = false
    
    static var passengers = [PassengerDTO]()
    static var selectPassengers = [PassengerDTO]()
    static var isGetPassengersInfo = false
    
    static var selectedTicket:QueryLeftNewDTO?
    
    static var orderId:String?
    
    static var globalRepeatSubmitToken:String?
    static var key_check_isChange:String?
    static var train_location:String?
    //"'ypInfoDetail':'O047850026O047853081M059350008'"
    static var ypInfoDetail:String?
    static var trainDate:String?
    
    static var historyOrderList:[OrderDTO] = []
    static var noCompleteOrderList:[OrderDTO] = []
    
    //parse ticket price
    static func ticketPriceBy(_ indentifier:String, ticketPriceInfo: String?, seatTypes: String?) -> Double{
        if let ticketInfo = ticketPriceInfo {
            var start = ticketInfo.startIndex
            var end = ticketInfo.index(start, offsetBy: 5)
            for seatType in seatTypes!.characters{
                if seatType == indentifier.characters[indentifier.startIndex] {
                    break;
                }
                start = ticketInfo.index(start, offsetBy: 10)
                end = ticketInfo.index(start, offsetBy: 5)
            }
            let priceStr = ticketInfo[ticketInfo.index(after: start)..<ticketInfo.index(after: end)]
            let price = Double(priceStr)! / 10
            return price
        } else {
            return 0
        }
    }
    
    static var ticketPrice:Double {
        get{
            var totalPrice:Double = 0
            for passenger in MainModel.selectPassengers{
                totalPrice += ticketPriceBy(passenger.seatCode,ticketPriceInfo: ypInfoDetail,seatTypes: selectedTicket?.seat_types)
            }
            return totalPrice
        }
    }
}

