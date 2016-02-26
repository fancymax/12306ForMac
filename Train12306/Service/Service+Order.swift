//
//  PcHTTPService+Order.swift
//  Train12306
//
//  Created by fancymax on 15/11/8.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa
import Alamofire
import PromiseKit

extension Service{
    internal func getPassengerStr(passengers:[PassengerDTO]) ->(String,String){
        var passengerStr = ""
        var oldPassengerStr = ""
        var i = 0
        for p in passengers {
            if p.isChecked{
                passengerStr += p.seatCode + "," + p.passenger_type! + "," + p.ticketCode + "," + p.passenger_name! + "," + p.passenger_id_type_code! + "," + p.passenger_id_no! + "," + p.mobile_no! + "," + "N"
                
                oldPassengerStr += p.passenger_name! + "," + p.passenger_id_type_code! + "," + p.passenger_id_no! + "," + p.ticketCode + "_"
                
                if i+1 < passengers.count{
                    passengerStr += "_"
                }
            }
            i++
        }
        return (passengerStr,oldPassengerStr)
    }
    
    func postMobileGetPassengerDTOs()
    {
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(.POST, url, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    print(error)
                case .Success(let data):
                    let jsonData = JSON(data)["data"]
                    guard jsonData["normal_passengers"].count > 0 else {
                        logger.error("\(jsonData)")
                        return
                    }
                    var passengers = [PassengerDTO]()
                    for i in 0...jsonData["normal_passengers"].count - 1{
                        passengers.append(PassengerDTO(jsonData:jsonData["normal_passengers"][i]))
                    }
                    if !MainModel.isGetPassengersInfo {
                        MainModel.passengers = passengers
                        MainModel.isGetPassengersInfo = true
                    }
                }})
    }
    
    func preOrderFlow(success success:(image:NSImage) -> (),failure: ()->()){
        self.checkUser().then({() ->Promise<Void> in
            return self.submitOrderRequest()
        }).then({ _ -> Promise<String> in
            return self.initDC()
        }).then({_ -> Promise<String> in
            return self.getPassengerDTOs()
        }).then({_ -> Promise<NSImage> in
            return self.getPassCodeNewForPassenger()
        }).then({image in
            success(image: image)
        }).error({_ in
            failure()
        })
        
    }
    
    func checkUser()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/checkUser"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if JSON(data)["data"]["flag"].bool == true{
                        fulfill()
                    }else {
                        logger.error("\(JSON(data))")
                        reject(NSError(domain: "checkUser", code: 0, userInfo: nil))
                    }
                }})
        }
    }
    
    func submitOrderRequest()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/leftTicket/submitOrderRequest"
            let params = [
                "secretStr":MainModel.selectedTicket!.SecretStr!,
                "train_date":MainModel.selectedTicket!.startTrainDateStr!,//2015-11-17
                "back_train_date":MainModel.selectedTicket!.startTrainDateStr!,//2015-11-03
                "tour_flag":"dc",
                "purpose_codes":"ADULT",
                "query_from_station_name":MainModel.selectedTicket!.FromStationName!,
                "query_to_station_name":MainModel.selectedTicket!.ToStationName!,
                "undefined":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(_):
                    fulfill()
                }})
        }
    }
    
    func initDC()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/initDc"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseString(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let content):
                    if let matches = Regex("var globalRepeatSubmitToken = '([^']+)'").getMatches(content){
                        MainModel.globalRepeatSubmitToken = matches[0][0]
                    }
                    else{
                        logger.error("fail to get globalRepeatSubmitToken:\(content)")
                    }
                    
                    if let matches = Regex("'key_check_isChange':'([^']+)'").getMatches(content){
                        MainModel.key_check_isChange = matches[0][0]
                    }
                    else{
                        logger.error("fail to get key_check_isChange:\(content)")
                        reject(NSError(domain: "initDC", code: 0, userInfo: nil))
                    }
                    
                    if let matches = Regex("'train_location':'([^']+)'").getMatches(content){
                        MainModel.train_location = matches[0][0]
                    }
                    else{
                        logger.error("fail to get train_location:\(content)")
                    }
                    
                    if let matches = Regex("'ypInfoDetail':'([^']+)'").getMatches(content){
                        MainModel.ypInfoDetail = matches[0][0]
                    }
                    else{
                        logger.error("fail to get ypInfoDetail:\(content)")
                    }
                    fulfill(url)
                }})
        }
    }
    
    func getPassengerDTOs()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
            let params = ["_json_att":"","REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let jsonData = JSON(data)["data"]
                    if jsonData["normal_passengers"].count == 0 {
                        logger.error("\(jsonData)")
                        reject(NSError(domain: "getPassengerDTOs", code: 0, userInfo: nil))
                    }
                    var passengers = [PassengerDTO]()
                    for i in 0...jsonData["normal_passengers"].count - 1{
                        passengers.append(PassengerDTO(jsonData:jsonData["normal_passengers"][i]))
                    }
                    if !MainModel.isGetPassengersInfo {
                        MainModel.passengers = passengers
                        MainModel.isGetPassengersInfo = true
                    }
                    fulfill(url)
                }})
        }
    }
    
    func getPassCodeNewForPassenger()->Promise<NSImage>{
        return Promise{ fulfill, reject in
            let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))//0~1
            let url = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=passenger&rand=randp&" + random.description
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.GET, url, headers:headers).responseData({response in
                    switch (response.result){
                    case .Failure(let error):
                        reject(error)
                    case .Success(let data):
                        fulfill(NSImage(data: data)!)
                }})
        }
    }
    
    func orderFlowWith(randCodeStr:String,success:()->(),failure:()->()){
        self.checkRandCodeForOrder(randCodeStr).then({_ -> Promise<String> in
            return self.checkOrderInfo(randCodeStr)
        }).then({_ -> Promise<String> in
            return self.getQueueCount()
        }).then({_ -> Promise<Void> in
            return after(1)
        }).then({()-> Promise<String> in
            return self.confirmSingleForQueue(randCodeStr)
        }).then({_ -> Promise<Void> in
            return after(1)
        }).then({()->Promise<Bool> in
            return self.queryOrderWaitTime()
        }).then({ isReady -> Promise<Bool> in
            if !isReady{
                return after(2).then({
                    return self.queryOrderWaitTime()
                })
            }
            else{
                return self.queryOrderWaitTime()
            }
        }).then({_ in
            success()
        }).error({_ in
            failure()
        })
    }
    
    func checkRandCodeForOrder(randCodeStr:String) ->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
            let params = [
                "randCode":randCodeStr,
                "rand":"randp",
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if JSON(data)["data"]["result"].string == "1"{
                        fulfill(url)
                    }
                    else {
                        logger.error("\(JSON(data))")
                        reject(NSError(domain: "checkRandCodeForOrder", code: 0, userInfo: nil))
                    }
                }})
        }
    }
    
    func checkOrderInfo(randCodeStr:String)->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/checkOrderInfo"
            let (passengerTicketStr,oldPassengerStr) = getPassengerStr(MainModel.passengers)
            let params = [
                "cancel_flag":"2",
                "bed_level_order_num":"000000000000000000000000000000",
                "passengerTicketStr":passengerTicketStr,
                "oldPassengerStr":oldPassengerStr,
                "tour_flag":"dc",
                "randCode":randCodeStr,
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if JSON(data)["data"]["submitStatus"].bool == true{
                        fulfill(url)
                    }else{
                        logger.error("\(JSON(data))")
                        reject(NSError(domain: "checkOrderInfo", code: 0, userInfo: nil))
                    }
                }})
        }
    }
    
    func getQueueCount()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/getQueueCount"
            let params = [
                "train_date":MainModel.selectedTicket!.jsStartTrainDateStr!,//Tue+Nov+17+2015+00%3A00%3A00+GMT%2B0800
                "train_no":MainModel.selectedTicket!.train_no!,
                "stationTrainCode":MainModel.selectedTicket!.TrainCode!,
                "seatType":"O",
                "fromStationTelecode":MainModel.selectedTicket!.FromStationCode!,
                "toStationTelecode":MainModel.selectedTicket!.ToStationCode!,
                "leftTicket":MainModel.selectedTicket!.yp_info!,
                "purpose_codes":"00",//注意这里是00
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let json = JSON(data)
                    logger.debug("\(json)")
                    fulfill(url)
                }})
        }
    }
    
    func confirmSingleForQueue(randCodeStr:String) ->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/confirmSingleForQueue"
            let (passengerTicketStr,oldPassengerStr) = getPassengerStr(MainModel.passengers)
            let params = [
                "passengerTicketStr":passengerTicketStr,
                "oldPassengerStr":oldPassengerStr,
                "randCode":randCodeStr,
                "purpose_codes":"00",
                "key_check_isChange":MainModel.key_check_isChange!,
                "leftTicketStr":MainModel.selectedTicket!.yp_info!,
                "train_location":MainModel.train_location!,
                "roomType":"00",
                "dwAll":"N",
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if JSON(data)["data"]["submitStatus"].bool == true{
                        logger.debug("confirmSingleForQueueForPC submitStatus: true")
                        fulfill(url)
                    }else {
                        logger.error("\(JSON(data))")
                        reject(NSError(domain: "confirmSingleForQueue", code: 0, userInfo: nil))
                    }
                }})
        }
    }
    
    func queryOrderWaitTime() ->Promise<Bool>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/queryOrderWaitTime?"
            let params = "random=1446560572126&tourFlag=dc&_json_att=&REPEAT_SUBMIT_TOKEN=\(MainModel.globalRepeatSubmitToken!)"
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.GET, url + params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if let orderId = JSON(data)["data"]["orderId"].string{
                        MainModel.orderId = orderId
                        fulfill(true)
                    }
                    else{
                        logger.error("\(JSON(data))")
                        fulfill(false)
                    }
                }})
        }
    }
    
}
