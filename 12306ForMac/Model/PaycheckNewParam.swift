//
//  paycheckNewParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/11/30.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct PaycheckNewParam {

    func ToPostParams()->[String:String]{
        return [
            "batch_nos":"",
            "coach_nos":"",
            "seat_nos":"",
            "passenger_id_types":"",
            "passenger_id_nos":"",
            "passenger_names":"",
            "insure_price_all":"",
            "insure_types":"",
            "if_buy_insure_only":"N",
            "hasBoughtIns":"",
            "json_att":""
        ]
    }
}
