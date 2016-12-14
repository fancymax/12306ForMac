//
//  getQueueCountParam.swift
//  12306ForMac
//
//  Created by fancymax on 2016/12/14.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct GetQueueCountParam{
    
    init(with selectedTicket:QueryLeftNewDTO, seatCode:String, trainLocation:String, globalSubmitToken:String) {
        train_date = selectedTicket.jsStartTrainDateStr!
        train_no = selectedTicket.train_no!
        stationTrainCode = selectedTicket.TrainCode!
        seatType = seatCode
        fromStationTelecode = selectedTicket.FromStationCode!
        toStationTelecode = selectedTicket.ToStationCode!
        leftTicket = selectedTicket.yp_info!
        train_location = trainLocation
        REPEAT_SUBMIT_TOKEN = globalSubmitToken
    }
    
    var train_date = ""
    var train_no = ""
    var stationTrainCode = ""
    var seatType = ""
    var fromStationTelecode = ""
    var toStationTelecode = ""
    var leftTicket = ""
    var purpose_codes = "00"
    var train_location = ""
    
    var REPEAT_SUBMIT_TOKEN = ""
    
    func ToPostParams()->[String:String]{
        return [
            "train_date":train_date,
            "train_no":train_date,//2015-11-17
            "tour_flag":train_no,
            "stationTrainCode":stationTrainCode,
            "seatType":seatType,
            "fromStationTelecode":fromStationTelecode,
            "toStationTelecode":toStationTelecode,
            "leftTicket":leftTicket,
            "purpose_codes":purpose_codes,
            "train_location":train_location,
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":REPEAT_SUBMIT_TOKEN]
    }
}
