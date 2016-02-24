//
//  LeftTicketDTO.swift
//  Train12306
//
//  Created by fancymax on 15/10/24.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

struct LeftTicketParam{
    //2015-09-23
    var train_date = "2015-09-23"
    //SZQ  ->  深圳
    var from_station = "SZQ"
    //SHH  ->  上海
    var to_station = "SHH"
    //ADULT
    var purpose_codes = "ADULT"
    
    func ToGetParams()->String{
        return "leftTicketDTO.train_date=\(train_date)&leftTicketDTO.from_station=\(from_station)&leftTicketDTO.to_station=\(to_station)&purpose_codes=\(purpose_codes)"
    }
}
