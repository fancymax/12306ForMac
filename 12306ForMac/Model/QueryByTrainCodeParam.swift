//
//  QueryByTrainCodeParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/06/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct QueryTrainCodeParam {
    let _train_no:String //6i000D232806"
    let _from_station_telecode:String // "IOQ"
    let _to_station_telecode:String //"FYS"
    let _depart_date:String  //2016-09-10 ！！列车出发时间！！
    
    init(_ ticket:QueryLeftNewDTO) {
        self.init(train_no:ticket.train_no,from_station_telecode:ticket.FromStationCode!,to_station_telecode:ticket.ToStationCode!,depart_date:ticket.start_train_date_formatStr!)
    }
    
    init(train_no:String,from_station_telecode:String,to_station_telecode:String,depart_date:String) {
        _train_no = train_no
        _from_station_telecode = from_station_telecode 
        _to_station_telecode = to_station_telecode 
        _depart_date = depart_date 
    }
    
    //train_no=6i000D232806&from_station_telecode=IOQ&to_station_telecode=FYS&depart_date=2016-06-12
    func ToGetParams()->String{
        return "train_no=\(_train_no)&from_station_telecode=\(_from_station_telecode)&to_station_telecode=\(_to_station_telecode)&depart_date=\(_depart_date)"
    }
}
