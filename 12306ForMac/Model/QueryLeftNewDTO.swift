//
//  TicketQueryResult.swift
//  Train12306
//
//  Created by fancymax on 15/8/1.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

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
    let start_station_name:String!

    let end_station_telecode:String!
    let end_station_name:String!
    
    let FromStationCode:String?
    let FromStationName:String?
    
    let ToStationName:String?
    let ToStationCode:String?
    
    let start_time:String!
    let arrive_time:String!
    
    let day_difference:String?
    let train_class_name:String?
    //"12:01"
    let lishi:String!
    //"Y"  "IS_TIME_NOT_BUY"预售期未到/系统维护时间
    let canWebBuy:String?
    //721
    let lishiValue:String?
    
    let yp_info:String?
    let control_train_day:String?
    let start_train_date:String!
    let controlled_train_flag:String?
    let seat_feature:String?
    
    //"yp_ex":"O0M0O0"
    let yp_ex:String?
    let train_seat_feature:String?
    let seat_types:String?
    let location_code:String?
    let from_station_no:String?
    let to_station_no:String?
    let control_day:Int?
    let sale_time:String?
    let is_support_card:String?
    //标识符
    var SecretStr:String?
    //票务描述
    var buttonTextInfo:String?
    //观光
//    var Gg_Num:String?
    //迎宾
//    var Yb_Num:String!
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
    
    func getSaleTime() -> Date {
        let beforeDays = control_day ?? 30
        let offsetHour = Int(sale_time!) ?? 0
        
        let offsetDay = 3600 * 24 * beforeDays
        let seconds = offsetHour / 100 * 3600
        let saleTime = trainDate.addingTimeInterval(-(Double)(offsetDay)).addingTimeInterval((Double)(seconds))
        
        return saleTime
    }
    
    func canTicketAdd2Calendar() -> Bool {
        if let str = buttonTextInfo {
            if str.contains("起售") {
                return true
            }
        }
        return false
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
            if (seatVal != "--") && (seatVal != "无") && (seatVal != "*"){
                seatInfos[seatName] = SeatTypePair(seatName: seatName, seatCode: seatTypeNameDic[seatName]!, hasTicket: true)
            }
        }
    }

    return seatInfos
}
    
    init(json:JSON,dateStr:String)
    {
        let ticket = json["queryLeftNewDTO"]
        train_no = ticket["train_no"].string
        TrainCode = ticket["station_train_code"].string
        
        start_station_telecode = ticket["start_station_telecode"].string
        start_station_name = ticket["start_station_name"].string
        
        end_station_telecode = ticket["end_station_telecode"].string
        end_station_name = ticket["end_station_name"].string
        
        FromStationName = ticket["from_station_name"].string
        FromStationCode = ticket["from_station_telecode"].string
        ToStationName = ticket["to_station_name"].string
        ToStationCode = ticket["to_station_telecode"].string
        start_time = ticket["start_time"].string
        arrive_time = ticket["arrive_time"].string
        lishi = ticket["lishi"].string
        start_train_date = ticket["start_train_date"].string
        controlled_train_flag = ticket["controlled_train_flag"].string
        
        day_difference = ticket["day_difference"].string
        train_class_name = ticket["train_class_name"].string
        canWebBuy = ticket["canWebBuy"].string
        lishiValue = ticket["lishiValue"].string
        yp_info = ticket["yp_info"].string
        control_train_day = ticket["control_train_day"].string
        seat_feature = ticket["seat_feature"].string
        yp_ex = ticket["yp_ex"].string
        train_seat_feature = ticket["train_seat_feature"].string
        seat_types = ticket["seat_types"].string
        location_code = ticket["location_code"].string
        from_station_no = ticket["from_station_no"].string
        to_station_no = ticket["to_station_no"].string
        control_day = ticket["control_day"].int
        sale_time = ticket["sale_time"].string
        is_support_card = ticket["is_support_card"].string
        
        Swz_Num = ticket["swz_num"].string
        Tz_Num = ticket["tz_num"].string
        Zy_Num = ticket["zy_num"].string
        Ze_Num = ticket["ze_num"].string
        Gr_Num = ticket["gr_num"].string
        Rw_Num = ticket["rw_num"].string
        Yw_Num = ticket["yw_num"].string
        Rz_Num = ticket["rz_num"].string
        Yz_Num = ticket["yz_num"].string
        Wz_Num = ticket["wz_num"].string
        Qt_Num = ticket["qt_num"].string
        
        SecretStr = json["secretStr"].string
        buttonTextInfo = json["buttonTextInfo"].string
        
        if SecretStr != nil{
            SecretStr = SecretStr!.removingPercentEncoding
        }
        
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

