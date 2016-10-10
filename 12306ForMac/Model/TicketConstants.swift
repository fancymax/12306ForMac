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

func QuerySeatTypeDicBy(_ trainCode:String)->[String:String] {
    if (trainCode.contains("G"))||(trainCode.contains("D")||(trainCode.contains("C"))) {
        return D_SEAT_TYPE_NAME_DIC;
    }
    else {
        return K_SEAT_TYPE_NAME_DIC;
    }
}

//20160502->2016-05-02
func Convert2StartTrainDateStr(_ dateStr: String)->String{
    var formateStr = dateStr
    var index = dateStr.characters.index(dateStr.startIndex, offsetBy: 4)
    formateStr.insert("-", at: index)
    index = dateStr.characters.index(dateStr.startIndex, offsetBy: 7)
    formateStr.insert("-", at: index)
    
    return formateStr
}

/*
     yp_info format:
 
     K2323
     1/02510/3186 :  无座/251元/186张
     4/06730/0005
     1/02510/0519
     3/04260/0116
     
     D2323
     O/07650/0604
     M/12075/0100
     9/23895/0024
*/
func getSeatInfosFrom(yp_info: String, trainCode: String)->[String: SeatTypePair] {
    var seatInfos  = [String:SeatTypePair]()
    let totalLength = yp_info.lengthOfBytes(using: String.Encoding.utf8)
    if totalLength == 0 {
        return seatInfos
    }

    let ticketLength = 10
    let priceOffset = 1
    let priceLength = 5
    let numberOffset = 6
    let numberLength = 4
    let idOffset = 0
    let idLength = 1
    
    var numberPrevPos = yp_info.startIndex
    var numberNextPos = yp_info.startIndex
    var pricePrevPos = yp_info.startIndex
    var priceNextPos = yp_info.startIndex
    var idPrevPos = yp_info.startIndex
    var idNextPos = yp_info.startIndex
    
    var id1 = "无座"
    var id2 = "1"
    var number = 0
    var price:Double = 0
    
    let seatTypeDic = QuerySeatTypeDicBy(trainCode)
    
    let totalTicketNumber = totalLength / ticketLength
    
    for _ in 1...totalTicketNumber {
        idPrevPos = yp_info.index(idPrevPos, offsetBy: idOffset)
        idNextPos = yp_info.index(idPrevPos, offsetBy: idLength)
        id2 = yp_info.substring(with: idPrevPos..<idNextPos)
        
        pricePrevPos = yp_info.index(pricePrevPos, offsetBy: priceOffset)
        priceNextPos = yp_info.index(pricePrevPos, offsetBy: priceLength)
        price = Double(yp_info.substring(with: pricePrevPos..<priceNextPos))! / 10
        
        numberPrevPos = yp_info.index(numberPrevPos, offsetBy: numberOffset)
        numberNextPos = yp_info.index(numberPrevPos, offsetBy: numberLength)
        number = Int(yp_info.substring(with: numberPrevPos..<numberNextPos))!
        
        if number >= 3000 {
            id1 = "无座"
            number -= 3000
        }
        else {
            for (seatTypeName,seatTypeId) in seatTypeDic {
                if (seatTypeId == id2) && (seatTypeName != "无座") {
                    id1 = seatTypeName
                }
            }
        }
        
        pricePrevPos = yp_info.index(pricePrevPos, offsetBy: ticketLength - priceOffset)
        numberPrevPos = yp_info.index(numberPrevPos, offsetBy: ticketLength - numberOffset)
        idPrevPos = yp_info.index(idPrevPos, offsetBy: ticketLength - idOffset)
        
        let seatType = SeatTypePair(id1: id1, id2: id2, number: number, price: price)
        seatInfos[id1] = seatType
    }
    return seatInfos
}


//let cardTypeNameDic = ["二代身份证": "1", "一代身份证": "2", "港澳通行证": "C", "台湾通行证": "G", "护照": "B"]
//
//let ticketTypeNameDic = ["成人票": "1", "儿童票": "2", "学生票": "3", "残军票": "4"]

