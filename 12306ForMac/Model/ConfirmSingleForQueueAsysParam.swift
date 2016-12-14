//
//  ConfirmSingleForQueueAsysParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/12/14.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct ConfirmSingleForQueueParamAsys{
    
    init(randCodeStr:String,passengerTicket:String,oldPassenger:String) {
        passengerTicketStr = passengerTicket
        oldPassengerStr = oldPassenger
        randCode = randCodeStr
        
        key_check_isChange = MainModel.key_check_isChange ?? ""
        leftTicketStr = MainModel.selectedTicket?.yp_info ?? ""
        train_location = MainModel.train_location ?? ""
    }
    
    var passengerTicketStr = ""
    var oldPassengerStr = ""
    var randCode = ""
    var purpose_codes = "ADULT"
    var key_check_isChange = ""
    var leftTicketStr = ""
    var train_location = ""
    
    var choose_seats = ""
    var seatDetailType = ""
    
    func ToPostParams()->[String:String]{
        return [
            "passengerTicketStr":passengerTicketStr,
            "oldPassengerStr":oldPassengerStr,
            "randCode":randCode,
            "purpose_codes":purpose_codes,
            "key_check_isChange":key_check_isChange,
            "leftTicketStr":leftTicketStr,
            "train_location":train_location,
            "choose_seats":choose_seats,
            "seatDetailType":seatDetailType,
            "_json_att":""]
    }
}
