//
//  OrderDTOData.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class OrderDTO:NSObject{
    var sequence_no: String?
    
    var start_train_date_page: String?
    var train_code_page: String?
    var ticket_total_price_page: String?
    var return_flag: String?
    var resign_flag: String?
    var arrive_time_page: String?
    
    //tickets[x]
    var coach_no: String? //车厢号  05
    var seat_name: String? //席位号  01A号
    var str_ticket_price_page: String? //票价  603.5
    var ticket_type_name: String? //票种  成人票
    var seat_type_name: String?  //席别  一等座
    var ticket_status_name: String? //状态  待支付
    var pay_limit_time: String? //限定支付时间  2016-06-14 10:36:28
    
    // stationTrainDTO
    var station_train_code: String? //G6012
    var from_station_name: String? //深圳北
    var to_station_name: String?  //长沙南
    
    //passengerDTO
    var passenger_name :String? //小明
    
    //modified
    //05车厢
    var coachName:String{
        var name = ""
        if let no = coach_no {
            name = no + "车厢"
        }
        return name
    }
    
    var startEndStation:String {
        return "\(from_station_name!)->\(to_station_name!)"
    }
    
    var whereToSeat:String {
        return "\(coachName) \(seat_name!)"
    }
    
    //¥603.5
    var ticketPrice:String{
        var name = ""
        if let price = str_ticket_price_page {
            name = "¥" + price
        }
        return name
    }
    
    var payStatus:String{
        var name = ""
        if let limitTime = pay_limit_time, status = ticket_status_name{
            name = "\(status)(请在 \(limitTime) 前支付)"
        }
        return name
    }
    
    init(json:JSON,ticketIdx:Int)
    {
        sequence_no = json["sequence_no"].string
        start_train_date_page = json["start_train_date_page"].string
        train_code_page = json["train_code_page"].string
        arrive_time_page = json["arrive_time_page"].string
        
        coach_no = json["tickets"][ticketIdx]["coach_no"].string
        seat_name = json["tickets"][ticketIdx]["seat_name"].string
        str_ticket_price_page = json["tickets"][ticketIdx]["str_ticket_price_page"].string
        ticket_type_name = json["tickets"][ticketIdx]["ticket_type_name"].string
        seat_type_name = json["tickets"][ticketIdx]["seat_type_name"].string
        ticket_status_name = json["tickets"][ticketIdx]["ticket_status_name"].string
        pay_limit_time = json["tickets"][ticketIdx]["pay_limit_time"].string
        
        station_train_code = json["tickets"][ticketIdx]["stationTrainDTO"]["station_train_code"].string
        from_station_name = json["tickets"][ticketIdx]["stationTrainDTO"]["from_station_name"].string
        to_station_name = json["tickets"][ticketIdx]["stationTrainDTO"]["to_station_name"].string
        
        passenger_name = json["tickets"][ticketIdx]["passengerDTO"]["passenger_name"].string
    }
    
    override init() {
        start_train_date_page = "2016-7-30 15:40"
        train_code_page = "D2612"
        
        coach_no = "08"
        seat_name = "06A号"
        str_ticket_price_page = "1024"
        ticket_type_name = "儿童票"
        seat_type_name = "商务座"
        
        station_train_code = "G6012"
        from_station_name =  "深圳北"
        to_station_name =  "长沙南"
    
        passenger_name = "小明"
//        return_flag = ""
//        resign_flag = ""
//        arrive_time_page = "19:09"
    }
    
}
