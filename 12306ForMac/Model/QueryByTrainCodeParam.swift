//
//  QueryByTrainCodeParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/06/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct QueryByTrainCodeParam {
    let train_no:String //6i000D232806"
    let from_station_telecode:String // "IOQ"
    let to_station_telecode:String //"FYS"
    let depart_date:String  //2016-09-10 ！！列车出发时间！！
    
    init(_ ticket:QueryLeftNewDTO) {
        train_no = ticket.train_no
        from_station_telecode = ticket.FromStationCode!
        to_station_telecode = ticket.ToStationCode!
        depart_date = ticket.start_train_date_formatStr!
    }
    
    //train_no=6i000D232806&from_station_telecode=IOQ&to_station_telecode=FYS&depart_date=2016-06-12
    func ToGetParams()->String{
        return "train_no=\(train_no)&from_station_telecode=\(from_station_telecode)&to_station_telecode=\(to_station_telecode)&depart_date=\(depart_date)"
    }
}
