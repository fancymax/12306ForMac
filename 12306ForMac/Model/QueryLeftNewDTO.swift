//
//  TicketQueryResult.swift
//  Train12306
//
//  Created by fancymax on 15/8/1.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa
import JavaScriptCore
/*
gg_num 	    观光
yb_num 	    迎宾
qt_num 	    其他

swz_num     商务座
tz_num 	    特等座
zy_num 	    一等座
ze_num 	    二等座
gr_num 	    高级软卧
rw_num      软卧
yw_num 	    硬卧
rz_num 	    软座
yz_num 	    硬座
wz_num 	    无座
*/

class QueryLeftNewDTO:NSObject {
    var train_no:String?
    var TrainCode:String?
    var start_station_telecode:String?
    var start_station_name:String?

    var end_station_telecode:String?
    var end_station_name:String?
    
    var FromStationCode:String?
    var FromStationName:String?
    
    var ToStationName:String?
    var ToStationCode:String?
    
    var start_time:String?
    var arrive_time:String?
    
    var day_difference:String?
    var train_class_name:String?
    var lishi:String?               //"12:01"
    var canWebBuy:String?           //"Y"  "IS_TIME_NOT_BUY"预售期未到/系统维护时间
    var lishiValue:String?          //721
    var yp_info:String?             //"yp_info":"O021700228M026050032O021703072" 二等座228张 一等座32 无座72
    var control_train_day:String?
    var start_train_date:String?
    var seat_feature:String?
    var yp_ex:String?               //"yp_ex":"O0M0O0"
    var train_seat_feature:String?
    var seat_types:String?
    var location_code:String?
    var from_station_no:String?
    var to_station_no:String?
    var control_day:String?
    var sale_time:String?
    var is_support_card:String?
    
//    var hasTicket:Bool {
//        get {
//            if ((ticket == "--")||(ticket == "无")||(ticket == "*")){
//                return false
//            }
//            else {
//                return true
//            }
//        }
//    }
    
    var isStartStation:Bool{
        get{
            return FromStationCode == start_station_telecode
        }
    }
    
    var isEndStation:Bool{
        get{
            return ToStationCode == end_station_telecode
        }
    }
    
    var startTrainDate:NSDate?{
        get{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyymmdd"
            return dateFormatter.dateFromString(start_train_date!)
        }
    }
    
    //"2015-08-12"
    var startTrainDateStr:String?{
        get{
            //"20150926" - > "2015-09-26"
            func transformDateFormate(dateStr:String) -> String?
            {
                var formateStr = dateStr
                var index = dateStr.startIndex.advancedBy(4)
                formateStr.insert("-", atIndex: index)
                index = dateStr.startIndex.advancedBy(7)
                formateStr.insert("-", atIndex: index)
                
                return formateStr
            }
            return transformDateFormate(start_train_date!)
        }
    }
    
    //"Fri Dec 04 2015 08:00:00 GMT+0800 (中国标准时间)"
    var jsStartTrainDateStr:String?{
        get{
            let dateFormateStr = "EEE MMM dd yyyy '08:00:00' 'GMT'+'0800' '(中国标准时间)'"
            let local = NSLocale(localeIdentifier: "en-US")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = dateFormateStr
            dateFormatter.locale = local
            return dateFormatter.stringFromDate(startTrainDate!)
        }
    }
    
    func getTicketPriceBy(identifier:String) -> Double {
        let seatCode = MainModel.getSeatCodeBy(identifier, trainCode: TrainCode!)
        let price = MainModel.ticketPriceBy(seatCode, ticketPriceInfo: yp_info, seatTypes: seat_types)
        return price
    }
    
    var isSelected = false
    
    //标识符
    var SecretStr:String?
    //票务描述
    var buttonTextInfo:String?
    var Gg_Num:String?
    //高级软卧
    var Gr_Num:String?
    //其他
    var Qt_Num:String?
    //软卧
    var Rw_Num:String?
    //软座
    var Rz_Num:String?
    //特等座
    var Tz_Num:String?
    //无座
    var Wz_Num:String?
    var Yb_Num:String?
    //硬卧
    var Yw_Num:String?
    //硬座
    var Yz_Num:String?
    //二等座
    var Ze_Num:String?
    //一等座
    var Zy_Num:String?
    //商务座
    var Swz_Num:String?
    
    init(json:JSON)
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
        
        day_difference = ticket["start_train_date"].string
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
        
    }
}


//let yp_info = "O021700228M026050032O021703072"
//let yp_ex = "O0M0O0"
//
//let totalLen = yp_info.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
//
//let oneTicketLen = 10
//let preTicketInfoLen = 6
//let preTicketPriceLen = 1
//
//let circle = totalLen / oneTicketLen
//
//var numberPrevPos = yp_info.startIndex
//var numberNextPos = yp_info.startIndex
//
//var pricePrevPos = yp_info.startIndex
//var priceNextPos = yp_info.startIndex
//
//var number = 0
//var price = 0
//
//for index in 0...circle - 1 {
//    pricePrevPos = pricePrevPos.advancedBy(preTicketPriceLen)
//    priceNextPos = pricePrevPos.advancedBy(5)
//    price = Int(yp_info.substringWithRange(pricePrevPos..<priceNextPos))!
//    //    print("\(startPos1) ~ \(endPos1): \(ticketPrice) 元")
//    
//    numberPrevPos = numberPrevPos.advancedBy(preTicketInfoLen)
//    numberNextPos = numberPrevPos.advancedBy(4)
//    number = Int(yp_info.substringWithRange(numberPrevPos..<numberNextPos))!
//    //    print("\(startPos) ~ \(endPos): \(ticketNum) 张")
//    
//    pricePrevPos = pricePrevPos.advancedBy(oneTicketLen - preTicketPriceLen)
//    numberPrevPos = numberPrevPos.advancedBy(oneTicketLen - preTicketInfoLen)
//}
//
////let x1 = "
////1     02510   3186
////4     06730   0005
////1     02510   0519
////3     04260   0116"
//
////
////O     07650    0604
////M     12075    0100
////9     23895    0024
//
////1     01420    3000
////4     04200   0000
////1     01420   0000
////3     02690   0000
////
//
////O     03885   0000
////9     11945   0000
////O     03885   3000
////M     06035   0000
////
//
////O     03885   0154
////9     11945   0003
////O     03885   3024
////M     06035   0000
////
////