//
//  SubmitOrderParams.swift
//  12306ForMac
//
//  Created by fancymax on 2016/10/31.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct SubmitOrderParams{
    
    init(with ticket:QueryLeftNewDTO, purposeCode:String) {
        secretStr = ticket.SecretStr!
        train_date = ticket.trainDateStr
        back_train_date = ticket.trainDateStr
        //tour_flag  dc
        purpose_codes = purposeCode
        query_from_station_name = ticket.FromStationName!
        query_to_station_name = ticket.ToStationName!
        
    }
    
    var secretStr = ""
    
    var train_date = ""
    
    var back_train_date = ""
    
    let tour_flag = "dc"
    
    var purpose_codes = "ADULT"
    
    var query_from_station_name = ""
    
    var query_to_station_name = ""
    
    func ToPostParams()->[String:String]{
        return [
            "secretStr":secretStr,
            "train_date":train_date,//2015-11-17
            "back_train_date":back_train_date,//2015-11-03
            "tour_flag":tour_flag,
            "purpose_codes":purpose_codes,
            "query_from_station_name":query_from_station_name,
            "query_to_station_name":query_to_station_name,
            "undefined":""]
    }
}