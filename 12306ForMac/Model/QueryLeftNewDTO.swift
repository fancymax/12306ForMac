//
//  TicketQueryResult.swift
//  Train12306
//
//  Created by fancymax on 15/8/1.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

struct SeatTypePair:CustomDebugStringConvertible {
    let id1:String //无座
    let id2:String // 1
    let number:Int
    let price:Double
    
    init(id1:String,id2:String,number:Int,price:Double) {
        self.id1 = id1
        self.id2 = id2
        self.number = number
        self.price = price
    }
    
    var debugDescription: String {
        return "id1:\(id1) id:\(id2) number:\(number) price:\(price)"
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
    
    let start_time:String?
    let arrive_time:String?
    
    let day_difference:String?
    let train_class_name:String?
    //"12:01"
    let lishi:String?
    //"Y"  "IS_TIME_NOT_BUY"预售期未到/系统维护时间
    let canWebBuy:String?
    //721
    let lishiValue:String?
    
    //"yp_info":"O021700228M026050032O021703072" 二等座228张 一等座32 无座72
    //1016303004
    //4047100000
    //1016300000
    //3030400000
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
    let control_day:String?
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
    
//MARK: Train Date
    var trainDate:NSDate!
//    yyyy-MM-dd
    let trainDateStr:String
    
    private func trainDateStr2Date(dateStr:String)->NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.dateFromString(dateStr) {
            return date
        }
        else {
            logger.error("trainDateStr2Date dateStr = \(dateStr)")
            return NSDate()
        }
    }
    
    //"Fri Dec 04 2015 08:00:00 GMT+0800 (中国标准时间)"
    var jsStartTrainDateStr:String!
    private func getJsStartTrainDateStr(date:NSDate)->String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd yyyy '00:00:00' 'GMT'+'0800' '(CST)'"
        dateFormatter.locale = NSLocale(localeIdentifier: "en-US")
        return dateFormatter.stringFromDate(date)
    }
    
//MARK: Seat and Ticket
    func hasTicketForSeatTypeFilterKey(key:String) -> Bool {
        for val in seatTypePairDic.values {
            if ((key.containsString(val.id1))&&(val.number > 0)) {
                return true
            }
        }
        return false
    }
    
    func getSeatTypeNameByFilterKey(key:String) -> String? {
        for val in seatTypePairDic.values {
            if ((key.containsString(val.id1))&&(val.number > 0)) {
                return val.id1
            }
        }
        return nil
    }
    
    func setupHasTicket(){
        for val in seatTypePairDic.values {
            if val.number > 0 {
                hasTicket = true
                return
            }
        }
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
        control_day = ticket["control_day"].string
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
            SecretStr = SecretStr!.stringByRemovingPercentEncoding
        }
        
        isStartStation = (FromStationCode == start_station_telecode)
        isEndStation = (ToStationCode == end_station_telecode)
        
        trainDateStr = dateStr
        
        super.init()
        
        trainDate = trainDateStr2Date(dateStr)
        jsStartTrainDateStr = getJsStartTrainDateStr(trainDate)
        seatTypePairDic = getSeatInfosFrom(yp_info: yp_info!, trainCode: TrainCode)
        setupHasTicket()
    }
    
}

