//
//  Passenger.swift
//  Train12306
//
//  Created by fancymax on 15/8/24.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class PassengerDTO:NSObject,Printable {
    
    override var description:String{
        return "name:\(passenger_name) sex:\(sex_name)"
    }
    
    var code :String?
    var passenger_name :String?
    var sex_code :String?
    var sex_name :String?
    var born_date :String?
    var country_code :String?
    var passenger_id_type_code :String?
    var passenger_id_type_name :String?
    var passenger_id_no :String?
    var passenger_type :String?
    var passenger_flag :String?
    var passenger_type_name :String?
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
    var seatCodeName = "";
    var ticketCode = "1";
    var ticketCodeName = "成人票";
    
    init(jsonData:JSON)
    {
        isChecked = false
        
        code = jsonData["code"].string
        passenger_name = jsonData["passenger_name"].string
        sex_code = jsonData["sex_code"].string
        sex_name = jsonData["sex_name"].string
        born_date = jsonData["born_date"].string
        country_code = jsonData["country_code"].string
        passenger_id_type_code = jsonData["passenger_id_type_code"].string
        passenger_id_type_name = jsonData["passenger_id_type_name"].string
        passenger_id_no = jsonData["passenger_id_no"].string
        passenger_type = jsonData["passenger_type"].string
        passenger_flag = jsonData["passenger_flag"].string
        passenger_type_name = jsonData["passenger_type_name"].string
        mobile_no = jsonData["mobile_no"].string
        phone_no = jsonData["phone_no"].string
        email = jsonData["email"].string
        address = jsonData["address"].string
        postalcode = jsonData["postalcode"].string
        first_letter = jsonData["first_letter"].string
        recordCount = jsonData["recordCount"].string
        total_times = jsonData["total_times"].string
        index_id = jsonData["index_id"].string
    }
}
