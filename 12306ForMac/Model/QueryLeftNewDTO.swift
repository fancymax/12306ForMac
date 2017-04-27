//
//  QueryLeftNewDTO.swift
//  12306ForMac
//
//  Created by fancymax on 15/8/1.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa
import SwiftyJSON

struct SeatTypePair:CustomDebugStringConvertible {
    let seatName:String //无座
    let seatCode:String // 1
    let hasTicket:Bool
    
    init(seatName:String,seatCode:String,hasTicket:Bool) {
        self.seatName = seatName
        self.seatCode = seatCode
        self.hasTicket = hasTicket
    }
    
    var debugDescription: String {
        return "seatName:\(seatName) seatCode:\(seatCode) hasTicket:\(hasTicket)"
    }
}

enum TicketOrder:String {
    case StartTime
    case ArriveTime
    case Lishi
}

class QueryLeftNewDTO:NSObject {

    
// MARK: JSON Property
    let train_no:String!
    let TrainCode:String!
    let start_station_telecode:String!

    let end_station_telecode:String!
    
    let FromStationCode:String!
    let FromStationName:String!
    
    let ToStationName:String!
    let ToStationCode:String!
    
    let start_time:String!
    let arrive_time:String!
    
    //"12:01"
    let lishi:String!
    //"Y"  "IS_TIME_NOT_BUY"预售期未到/系统维护时间
    let canWebBuy:String?
    
    let yp_info:String?
    let start_train_date:String!
    let controlled_train_flag:String?
    
    //"yp_ex":"O0M0O0"
    let yp_ex:String?
    let train_seat_feature:String?
    let seat_types:String?
    let location_code:String?
    let from_station_no:String?
    let to_station_no:String?
    let is_support_card:String?
    //标识符
    var SecretStr:String?
    //票务描述
    var buttonTextInfo:String
    //观光
    var Gg_Num:String!
    //迎宾
    var Yb_Num:String!
    //高级软卧
    let Gr_Num:String!
    //其他
    let Qt_Num:String!
    //软卧
    let Rw_Num:String!
    //软座
    let Rz_Num:String!
    //特等座
    let Tz_Num:String!
    //无座
    let Wz_Num:String!
    //硬卧
    let Yw_Num:String!
    //硬座
    let Yz_Num:String!
    //二等座
    let Ze_Num:String!
    //一等座
    let Zy_Num:String!
    //商务座
    let Swz_Num:String!
    
// MARK: Custom Property
    var seatTypePairDic = [String:SeatTypePair]()
    
    let isStartStation:Bool
    let isEndStation:Bool
    
    var hasTicket:Bool = false
    
    func isTicketInvalid() -> Bool {
        if controlled_train_flag == "1" {
            return true
        }
        else {
            return false
        }
    }
    
    func canTicketAdd2Calendar() -> Bool {
        if buttonTextInfo.contains("起售") {
            return true
        }
        else {
            return false
        }
    }
    
//MARK: Train Date
    var trainDate:Date!
//    yyyy-MM-dd
    let trainDateStr:String
    
    var start_train_date_formatStr:String!
    
    private func getFormatStartTrainStr(_ dateStr:String)->String {
        let startIndex = dateStr.startIndex
        
        var resStr = dateStr
        resStr.insert("-", at: resStr.index(startIndex, offsetBy: 4))
        resStr.insert("-", at: resStr.index(startIndex, offsetBy: 7))
        
        return resStr
    }
    
    private func trainDateStr2Date(_ dateStr:String)->Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        else {
            logger.error("trainDateStr2Date dateStr = \(dateStr)")
            return Date()
        }
    }
    
    //"Fri Dec 04 2015 08:00:00 GMT+0800 (中国标准时间)"
    var jsStartTrainDateStr:String!
    fileprivate func getJsStartTrainDateStr(_ date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd yyyy '00:00:00' 'GMT'+'0800' '(CST)'"
        dateFormatter.locale = Locale(identifier: "en-US")
        return dateFormatter.string(from: date)
    }
    
//MARK: Seat and Ticket
    func hasTicketForSeatTypeFilterKey(_ key:String) -> Bool {
        for val in seatTypePairDic.values {
            if ((key.contains(val.seatName))&&(val.hasTicket)) {
                return true
            }
        }
        return false
    }
    
    func getSeatTypeNameByFilterKey(_ key:String) -> String? {
        for val in seatTypePairDic.values {
            if ((key.contains(val.seatName))&&(val.hasTicket)) {
                return val.seatName
            }
        }
        return nil
    }
    
    func setupHasTicket(){
        for val in seatTypePairDic.values {
            if val.hasTicket {
                hasTicket = true
                return
            }
        }
    }
    
    
func getSeatInfosFrom(trainCode:String)->[String:SeatTypePair] {
    var seatInfos  = [String:SeatTypePair]()
    
    let seatTypeNameDic = G_QuerySeatTypeNameDicBy(trainCode)
    let seatTypeKeyPathDic = G_QuerySeatTypeKeyPathDicBy(trainCode)
    for seatName in seatTypeNameDic.keys {
        if let keyPath = seatTypeKeyPathDic[seatName] {
            let seatVal = self.value(forKey: keyPath) as! String
            if (seatVal != "--") && (seatVal != "无") && (seatVal != "*")&&(seatVal != ""){
                seatInfos[seatName] = SeatTypePair(seatName: seatName, seatCode: seatTypeNameDic[seatName]!, hasTicket: true)
            }
        }
    }

    return seatInfos
}
    
    init(json:JSON, map:JSON, dateStr:String)
    {
        let paramStr = json.rawString()!
        let params = paramStr.components(separatedBy: "|")
        
        SecretStr = params[0]
        if SecretStr != nil{
            SecretStr = SecretStr!.removingPercentEncoding
        }
        buttonTextInfo = params[1]
        train_no = params[2]
        TrainCode = params[3]
        start_station_telecode = params[4]
        end_station_telecode = params[5]
        FromStationCode = params[6]
        ToStationCode = params[7]
        start_time = params[8]
        arrive_time = params[9]
        lishi = params[10]
        canWebBuy = params[11]
        yp_info = params[12]
        start_train_date = params[13]
        train_seat_feature = params[14]
        location_code = params[15]
        from_station_no = params[16]
        to_station_no = params[17]
        is_support_card = params[18]
        controlled_train_flag = params[19]
        
        Gg_Num = params[20]
        Gr_Num = params[21]
        Qt_Num = params[22]
        Rw_Num = params[23]
        Rz_Num = params[24]
        Tz_Num = params[25]
        Wz_Num = params[26]
        Yb_Num = params[27]
        Yw_Num = params[28]
        Yz_Num = params[29]
        Ze_Num = params[30]
        Zy_Num = params[31]
        Swz_Num = params[32]
        
        yp_ex = params[33]
        seat_types = params[34]
        
        FromStationName = map[FromStationCode].stringValue
        ToStationName = map[ToStationCode].stringValue
        
        isStartStation = (FromStationCode == start_station_telecode)
        isEndStation = (ToStationCode == end_station_telecode)
        
        trainDateStr = dateStr
        
        super.init()
        
        start_train_date_formatStr = getFormatStartTrainStr(start_train_date)
        
        trainDate = trainDateStr2Date(dateStr)
        jsStartTrainDateStr = getJsStartTrainDateStr(trainDate)
        seatTypePairDic = getSeatInfosFrom(trainCode: TrainCode)
        setupHasTicket()
    }
    
}

