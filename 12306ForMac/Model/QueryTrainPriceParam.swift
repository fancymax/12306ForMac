//
//  QueryTrainPriceParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/11/8.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct QueryTrainPriceParam {
    let train_no:String // "6i000D232806"
    let from_station_no:String // "01"
    let to_station_no:String // "14"
    let seat_types:String // "OM9"
    let train_date:String //  "2016-12-29"
    
    init(_ ticket:QueryLeftNewDTO) {
        train_no = ticket.train_no
        from_station_no = ticket.from_station_no!
        to_station_no = ticket.to_station_no!
        seat_types = ticket.seat_types!
        train_date = ticket.trainDateStr
    }
    
    //?train_no=6i000G160202&from_station_no=01&to_station_no=14&seat_types=OM9&train_date=2016-12-2
    func ToGetParams()->String{
        return "train_no=\(train_no)&from_station_no=\(from_station_no)&to_station_no=\(to_station_no)&seat_types=\(seat_types)&train_date=\(train_date)"
    }
}

