//
//  Passenger.swift
//  Train12306
//
//  Created by fancymax on 15/8/24.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class PassengerDTO:NSObject {
    
    let code :String
    let passenger_name :String
    var sex_code :String?
    var sex_name :String?
    var born_date :String?
    var country_code :String?
    let passenger_id_type_code :String
    var passenger_id_type_name :String?
    let passenger_id_no :String
    let passenger_type :String
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
        passenger_id_type_name = json["passenger_id_type_name"].string
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
}
