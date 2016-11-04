//
//  Passenger.swift
//  Train12306
//
//  Created by fancymax on 15/8/24.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

enum TicketType:String,CustomStringConvertible {
    case Student = "0X00"
    case Normal = "ADULT"
    
    var description: String {
        switch self {
        case .Student:
            return "学生"
        case .Normal:
            return "成人"
        }
    }
    
    var id_type_code:String {
        switch self {
        case .Student:
            return "3"
        case .Normal:
            return "1"
        }
    }
}

class PassengerDTO:NSObject {
    
    let code :String
    let passenger_name :String
    var sex_code :String?
    var sex_name :String?
    var born_date :String?
    var country_code :String?
    var passenger_id_type_code :String
    var passenger_id_type_name :String
    let passenger_id_no :String
    var passenger_type :String
    var passenger_type_name :String?
    var passenger_flag :String?
    var mobile_no :String?
    var phone_no :String?
    var email :String?
    var address :String?
    var postalcode :String?
    var first_letter :String?
    var recordCount :String?
    var total_times :String?
    var index_id :String?
    
    var isChecked: Bool
    var seatCode = "O";
    var seatCodeName = "二等座";
    var canSelectTicketType = false
    
    let passenger_type_name_Dic = ["成人","学生"]
    var passenger_id_type_select_index = 0 {
        willSet {
            if passenger_type_name_Dic[newValue] == TicketType.Student.description {
                passenger_type = TicketType.Student.id_type_code
            }
            else {
                passenger_type = TicketType.Normal.id_type_code
            }
        }
    }
    
    
    init(json:JSON)
    {
        isChecked = false
        
        code = json["code"].string!
        passenger_name = json["passenger_name"].string!
        sex_code = json["sex_code"].string
        sex_name = json["sex_name"].string
        born_date = json["born_date"].string
        country_code = json["country_code"].string
        passenger_id_type_code = json["passenger_id_type_code"].string!
        passenger_id_type_name = json["passenger_id_type_name"].string!
        passenger_id_no = json["passenger_id_no"].string!
        passenger_type = json["passenger_type"].string!
        passenger_flag = json["passenger_flag"].string
        passenger_type_name = json["passenger_type_name"].string
        mobile_no = json["mobile_no"].string
        phone_no = json["phone_no"].string
        email = json["email"].string
        address = json["address"].string
        postalcode = json["postalcode"].string
        first_letter = json["first_letter"].string
        recordCount = json["recordCount"].string
        total_times = json["total_times"].string
        index_id = json["index_id"].string
        
    }
    
    func setDefaultTicketType(date:Date){
        let sysDate = LunarCalendarView.toUTCDateComponent(date)
        let availableMonth = [6,7,8,9,12,1,2,3]
        let isDateAvailable:Bool
        if (availableMonth.contains(sysDate.month!)) {
            isDateAvailable = true
        }
        else {
            isDateAvailable = false
        }
        
        let isSeatAvailable:Bool
        if ((seatCode == "O") || (seatCode == "1")) {
            isSeatAvailable = true
        }
        else {
            isSeatAvailable = false
        }
        
        let isStudent:Bool
        if passenger_type_name == "学生" {
           isStudent = true
        }
        else {
           isStudent = false
        }
        
        if isStudent {
            if isDateAvailable && isSeatAvailable {
                passenger_id_type_select_index = 1
                canSelectTicketType = true
            }
            else {
                passenger_id_type_select_index = 0
                canSelectTicketType = false
            }
        }
    }
}
