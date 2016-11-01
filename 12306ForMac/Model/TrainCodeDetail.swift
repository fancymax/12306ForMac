//
//  TrainCodeDetail.swift
//  12306ForMac
//
//  Created by fancymax on 2016/06/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

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
        
//        self.trainNos = json.map { (string,json) in
//            TrainCodeDetail(json: json)
//        }
    }
    
}


