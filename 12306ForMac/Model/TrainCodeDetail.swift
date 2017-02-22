//
//  TrainCodeDetail.swift
//  12306ForMac
//
//  Created by fancymax on 2016/06/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import Cocoa

class TrainCodeDetail: NSObject {
    var station_no: String! // = "1"
    var station_name: String! // = "深圳北"
    var arrive_time: String! // = "-----"
    var start_time: String! // = "16:07"
    var stopover_time: String! // = "----"
    var isEnable: Bool! // = True
    var textColor:NSColor!
    
    init(json:JSON) {
        station_no = json["station_no"].string
        station_name = json["station_name"].string
        arrive_time = json["arrive_time"].string
        start_time = json["start_time"].string
        stopover_time = json["stopover_time"].string
        isEnable = json["isEnabled"].boolValue
        if isEnable! {
            textColor = NSColor.black
        }
        else{
            textColor = NSColor.gray
        }
    }
    
}

class TrainCodeDetails: NSObject {
    var start_station_name: String! // = "深圳北"
    var station_train_code: String! // = "D2306"
    var train_class_name: String! // = "动车"
    var service_type: String! // = "1"
    var end_station_name: String! // = "福州南"
    
    var trainNos: [TrainCodeDetail]!
    
    init(json:JSON) {
        if json.count <= 0 {
            return
        }
        
        start_station_name = json[0]["start_station_name"].string
        station_train_code = json[0]["station_train_code"].string
        train_class_name = json[0]["train_class_name"].string
        service_type = json[0]["service_type"].string
        end_station_name = json[0]["end_station_name"].string
        
        self.trainNos = [TrainCodeDetail]()
        for i in 0..<json.count
        {
            let trainNo = TrainCodeDetail(json: json[i])
            self.trainNos.append(trainNo)
        }
    }
}

class TrainPrice: NSObject {
    //动车
    let SEAT_TYPE_NAME_DIC = ["A9":"商务座", "P":"特等座", "M":"一等座",  "O":"二等座", "F":"动车软卧", "A6":"高级软卧", "A4":"软卧",  "A3":"硬卧",  "A2":"软座",  "A1":"硬座"]
    var train_no: String!
    var trainPriceStr = ""
    init(json:JSON) {
        train_no = json["train_no"].string
        
        for key in SEAT_TYPE_NAME_DIC.keys {
            let price = json[key].string
            if price == nil || price == "" {
                continue
            }
            let onePriceStr = "\(SEAT_TYPE_NAME_DIC[key]!):\(price!)    "
            trainPriceStr += onePriceStr
        }
    }
}


