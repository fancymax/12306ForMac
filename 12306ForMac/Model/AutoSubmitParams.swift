//
//  autoSubmitParams.swift
//  12306ForMac
//
//  Created by fancymax on 2016/12/13.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct AutoSubmitParams{
    
    init(with ticket:QueryLeftNewDTO, purposeCode:String,passengerTicket:String,oldPassenger:String) {
        secretStr = ticket.SecretStr!
        train_date = ticket.trainDateStr
        purpose_codes = purposeCode
        query_from_station_name = ticket.FromStationName!
        query_to_station_name = ticket.ToStationName!
        
        passengerTicketStr = passengerTicket
        oldPassengerStr = oldPassenger
    }
    
    var secretStr = ""
    
    var train_date = ""
    
    let tour_flag = "dc"
    
    var purpose_codes = "ADULT"
    
    var query_from_station_name = ""
    
    var query_to_station_name = ""
    
    let cancel_flag = "2"
    
    let bed_level_order_num = "000000000000000000000000000000"
    
    var passengerTicketStr = ""
    var oldPassengerStr = ""
    
    func ToPostParams()->[String:String]{
        return [
            "secretStr":secretStr,
            "train_date":train_date,//2015-11-17
            "tour_flag":tour_flag,
            "purpose_codes":purpose_codes,
            "query_from_station_name":query_from_station_name,
            "query_to_station_name":query_to_station_name,
            "cancel_flag":cancel_flag,
            "bed_level_order_num":bed_level_order_num,
            "passengerTicketStr":passengerTicketStr,
            "oldPassengerStr":oldPassengerStr]
    }
}
