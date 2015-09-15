//
//  TicketQueryResult.swift
//  Train12306
//
//  Created by fancymax on 15/8/1.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class QueryLeftNewDTO:NSObject,Printable {
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
    var canWebBuy:String?           //"Y"
    var lishiValue:String?          //721
    var yp_info:String?
    var control_train_day:String?
    var start_train_date:String?
    var seat_feature:String?
    var yp_ex:String?
    var train_seat_feature:String?
    var seat_types:String?
    var location_code:String?
    var from_station_no:String?
    var to_station_no:String?
    var control_day:String?
    var sale_time:String?
    var is_support_card:String?
    
    var fromStationInfo:String{
        get{
            return FromStationName! + "\n" + start_time!
        }
    }
    
    var toStationInfo:String{
        get{
            return ToStationName! + "\n" + arrive_time!
        }
    }
    
    //"20150926" - > 2015-09-26
    private func getDateFrom(dateStr:String) -> NSDate?
    {
        var formateStr = dateStr
        var index = advance(dateStr.startIndex, 4)
        formateStr.insert("-", atIndex: index)
        index = advance(dateStr.startIndex, 7)
        formateStr.insert("-", atIndex: index)
        
        let dateFormatter = NSDateFormatter()
        return dateFormatter.dateFromString(formateStr)
    }
    
    var startTrainDate:NSDate?{
        get{
            return getDateFrom(start_train_date!)
        }
    }
    
    //密码
    var SecretStr:String?
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
    var Swz_Nu:String?
    
    init(jsonData:JSON)
    {
        train_no = jsonData["train_no"].string
        TrainCode = jsonData["station_train_code"].string
        
        start_station_telecode = jsonData["start_station_telecode"].string
        start_station_name = jsonData["start_station_name"].string
        
        end_station_telecode = jsonData["end_station_telecode"].string
        end_station_name = jsonData["end_station_name"].string
        
        FromStationName = jsonData["from_station_name"].string
        FromStationCode = jsonData["from_station_telecode"].string
        ToStationName = jsonData["to_station_name"].string
        ToStationCode = jsonData["to_station_telecode"].string
        start_time = jsonData["start_time"].string
        arrive_time = jsonData["arrive_time"].string
        lishi = jsonData["lishi"].string
        start_train_date = jsonData["start_train_date"].string
        
        day_difference = jsonData["start_train_date"].string
        train_class_name = jsonData["train_class_name"].string
        canWebBuy = jsonData["canWebBuy"].string
        lishiValue = jsonData["lishiValue"].string
        yp_info = jsonData["yp_info"].string
        control_train_day = jsonData["control_train_day"].string
        seat_feature = jsonData["seat_feature"].string
        yp_ex = jsonData["yp_ex"].string
        train_seat_feature = jsonData["train_seat_feature"].string
        seat_types = jsonData["seat_types"].string
        location_code = jsonData["location_code"].string
        from_station_no = jsonData["from_station_no"].string
        to_station_no = jsonData["to_station_no"].string
        control_day = jsonData["control_day"].string
        sale_time = jsonData["sale_time"].string
        is_support_card = jsonData["is_support_card"].string
        
        Swz_Nu = jsonData["swz_num"].string
        Tz_Num = jsonData["tz_num"].string
        Zy_Num = jsonData["zy_num"].string
        Ze_Num = jsonData["ze_num"].string
        Gr_Num = jsonData["gr_num"].string
        Rw_Num = jsonData["rw_num"].string
        Yw_Num = jsonData["yw_num"].string
        Rz_Num = jsonData["rz_num"].string
        Yz_Num = jsonData["yz_num"].string
        Wz_Num = jsonData["wz_num"].string
        Qt_Num = jsonData["qt_num"].string
    }
}