//
//  QueryByTrainCodeParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/06/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct QueryByTrainCodeParam {
    var train_no = "6i000D232806"
    var from_station_telecode = "IOQ"
    var to_station_telecode = "FYS"
    var depart_date = "2016-06-12"
    
    //train_no=6i000D232806&from_station_telecode=IOQ&to_station_telecode=FYS&depart_date=2016-06-12
    func ToGetParams()->String{
        return "train_no=\(train_no)&from_station_telecode=\(from_station_telecode)&to_station_telecode=\(to_station_telecode)&depart_date=\(depart_date)"
    }
}