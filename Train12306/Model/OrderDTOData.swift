//
//  OrderDTOData.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class OrderDTOData:NSObject{
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
    
    init(jsonData:JSON)
    {
        start_train_date_page = jsonData["start_train_date_page"].string
        train_code_page = jsonData["train_code_page"].string
        
        sequence_no = jsonData["start_station_telecode"].string
        ticket_total_price_page = jsonData["start_station_name"].string
        arrive_time_page = jsonData["arrive_time_page"].string
        
        for i in 0...jsonData["from_station_name_page"].count - 1{
            from_station_name_page.append(jsonData["from_station_name_page"][i].string!)
        }
        
        for i in 0...jsonData["to_station_name_page"].count - 1{
            to_station_name_page.append(jsonData["to_station_name_page"][i].string!)
        }
    }
    
    var orderStr:String{
        get{
            return "\(train_code_page!) \(start_train_date_page!)->\(arrive_time_page!) \(from_station_name_page[0])->\(to_station_name_page[0])"
        }
    }
    
}
