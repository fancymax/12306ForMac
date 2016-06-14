//
//  OrderDTOData.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class OrderDTO:NSObject{
    var array_passser_name_page:[String]?
    var start_train_date_page: String?
    var train_code_page: String?
    var sequence_no: String?
    var ticket_total_price_page: String?
    var from_station_name_page: [String] = []
    var to_station_name_page:[String] = []
    var return_flag: String?
    var resign_flag: String?
    var arrive_time_page: String?
    
    init(json:JSON)
    {
        start_train_date_page = json["start_train_date_page"].string
        train_code_page = json["train_code_page"].string
        
        sequence_no = json["sequence_no"].string
        ticket_total_price_page = json["ticket_total_price_page"].string
        arrive_time_page = json["arrive_time_page"].string
        
        for i in 0...json["from_station_name_page"].count - 1{
            from_station_name_page.append(json["from_station_name_page"][i].string!)
        }
        
        for i in 0...json["to_station_name_page"].count - 1{
            to_station_name_page.append(json["to_station_name_page"][i].string!)
        }
    }
    
    override init() {
        super.init()
        array_passser_name_page = ["小明", "小红"]
        start_train_date_page = "2016-7-30 15:40"
        train_code_page = "D2612"
        sequence_no = " "
        ticket_total_price_page = " "
        from_station_name_page = ["深圳北"]
        to_station_name_page = ["福州南"]
        return_flag = ""
        resign_flag = ""
        arrive_time_page = "19:09"
    }
    
    var orderStr:String{
        get{
            return "\(train_code_page!) \(start_train_date_page!)-\(arrive_time_page!) \(from_station_name_page[0])->\(to_station_name_page[0])"
        }
    }
    
}
