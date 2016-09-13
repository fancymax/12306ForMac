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
    
// MARK: - Request Flow
    func submitFlow(success success:() -> (),failure:(error:NSError)->()){
        self.checkUser().then({() ->Promise<Void> in
            return self.submitOrderRequest()
        }).then({_ in
            self.initDC()
        }).then({jsName->Promise<Void> in
            return self.requestDynamicJs(jsName, referHeader: ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"])
        }).then({_ in
            success()
        }).error({error in
            failure(error: error as NSError)
        })
    }
    
    func preOrderFlow(success success:(image:NSImage) -> (),failure: (error:NSError)->()){
        self.getPassengerDTOs().then({_ -> Promise<NSImage> in
            return self.getPassCodeNewForPassenger()
        }).then({image in
            success(image: image)
        }).error({error in
            failure(error: error as NSError)
        })
    }
    
    func orderFlowWith(randCodeStr:String,success:()->(),failure:(error:NSError)->(),wait:(info:String)->()){
        self.checkRandCodeForOrder(randCodeStr).then({_ -> Promise<Void> in
            return self.checkOrderInfo(randCodeStr)
        }).then({_ -> Promise<Void> in
            return self.getQueueCount()
        }).then({_ -> Promise<Void> in
            return after(1)
        }).then({_ -> Promise<Void> in
            return self.confirmSingleForQueue(randCodeStr)
        }).then({
            self.queryOrderWaitTime(failure, waitMethod: wait, finishMethod: success)
        }).error({error in
            failure(error: error as NSError)
        })
    }
    
    func cancelOrderWith(sequence_no:String,success:()->(),failure:(error:NSError)->()){
        self.cancelNoCompleteOrder(sequence_no).then({
            success()
        }).error({error in
            failure(error: error as NSError)
        })
    }
    
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
            i += 1
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
                    passengers.append(PassengerDTO(json:jsonData["normal_passengers"][i]))
                }
                if !MainModel.isGetPassengersInfo {
                    MainModel.passengers = passengers
                    MainModel.isGetPassengersInfo = true
                }
            }})
    }
    
    
// MARK: - Chainable Request
    func checkUser()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/checkUser"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if JSON(data)["data"]["flag"].bool == true{
                        fulfill()
                    }else {
                        let error = ServiceError.errorWithCode(.CheckUserFailed)
                        reject(error)
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
                case .Success(let data):
                    if let isTrue = JSON(data)["status"].bool where isTrue{
                        fulfill()
                    }
                    else {
                        logger.error("\(JSON(data))")
                        print(params)
                        let error:NSError
                        if let message = JSON(data)["messages"][0].string{
                            error = ServiceError.errorWithCode(.SubmitOrderFailed, failureReason: message)
                        }
                        else{
                            error = ServiceError.errorWithCode(.SubmitOrderFailed)
                        }
                        reject(error)
                    }
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
                        logger.debug("globalRepeatSubmitToken:\(MainModel.globalRepeatSubmitToken!)")
                    }
                    else{
                        logger.error("fail to get globalRepeatSubmitToken:\(content)")
                    }
                    
                    var dynamicJs = ""
                    if let matches = Regex("src=\"/otn/dynamicJs/([^\"]+)\"").getMatches(content){
                        dynamicJs = matches[0][0]
                        logger.debug("dynamicJs = \(dynamicJs)")
                    }
                    else{
                        logger.error("fail to get dynamicJs:\(content)")
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
                    
                    if let matches = Regex(",'train_date':'([^']+)',").getMatches(content){
                        MainModel.trainDate = matches[0][0]
                    }
                    else{
                        logger.error("fail to get trainDate:\(content)")
                    }
                    
                    //,'train_date':'20160913',
                    fulfill(dynamicJs)
                }})
        }
    }
    
    func getPassengerDTOs()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
            let params = ["_json_att":"","REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let json = JSON(data)["data"]
                    if json["normal_passengers"].count == 0 {
                        logger.error("\(json)")
                        reject(NSError(domain: "getPassengerDTOs", code: 0, userInfo: nil))
                    }
                    var passengers = [PassengerDTO]()
                    for i in 0...json["normal_passengers"].count - 1{
                        passengers.append(PassengerDTO(json:json["normal_passengers"][i]))
                    }
                    if !MainModel.isGetPassengersInfo {
                        MainModel.passengers = passengers
                        MainModel.isGetPassengersInfo = true
                    }
                    fulfill()
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
                        if let image = NSImage(data: data){
                            fulfill(image)
                        }
                        else{
                            let error = ServiceError.errorWithCode(.GetRandCodeFailed)
                            reject(error)
                        }
                }})
        }
    }
    
    func checkRandCodeForOrder(randCodeStr:String) ->Promise<Void>{
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
                        fulfill()
                    }
                    else {
                        logger.error("\(JSON(data))")
                        let error = ServiceError.errorWithCode(.CheckRandCodeFailed)
                        reject(error)
                    }
                }})
        }
    }
    
    func checkOrderInfo(randCodeStr:String)->Promise<Void>{
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
                        fulfill()
                    }else{
                        logger.error("\(JSON(data))")
                        if let errMsg = JSON(data)["data"]["errMsg"].string {
                            reject(ServiceError.errorWithCode(.CheckOrderInfoFailed,failureReason: errMsg))
                        }
                        else{
                            reject(ServiceError.errorWithCode(.CheckOrderInfoFailed))
                        }
                    }
                }})
        }
    }
    
    func getQueueCount()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/getQueueCount"
            let params = [
                "train_date":MainModel.selectedTicket!.jsStartTrainDateStr!,//Tue+Nov+17+2015+00%3A00%3A00+GMT%2B0800
                "train_no":MainModel.selectedTicket!.train_no!,
                "stationTrainCode":MainModel.selectedTicket!.TrainCode!,
                "seatType":MainModel.selectPassengers[0].seatCode,
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
                    fulfill()
                }})
        }
    }
    
    func confirmSingleForQueue(randCodeStr:String) ->Promise<Void>{
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
                        logger.debug("confirmSingleForQueue true")
                        fulfill()
                    }else {
                        logger.error("\(JSON(data))")
                        let error = ServiceError.errorWithCode(.ConfirmSingleForQueueFailed)
                        reject(error)
                    }
                }})
        }
    }
    
    func queryOrderWaitTime(failMethod:(error:NSError)->(), waitMethod :(info:String) -> (),finishMethod:()->()) {
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/queryOrderWaitTime?"
            let params = "random=1446560572126&tourFlag=dc&_json_att=&REPEAT_SUBMIT_TOKEN=\(MainModel.globalRepeatSubmitToken!)"
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
        
        func calcWaitSecond(waitTime:Int) -> Int {
            var p1 = waitTime * 2 / 3
            if p1 > 60 {
                p1 = 60
            }
            
            print("calcWaitTime=\(p1)")
            return p1
        }
        
            Service.Manager.request(.GET, url + params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    print(error)
                    failMethod(error:error as NSError)
                case .Success(let data):
                    print(JSON(data))
                    let waitTimeResult = QueryOrderWaitTimeResult(json: JSON(data)["data"])
                    if let submitStatus = waitTimeResult.queryOrderWaitTimeStatus where submitStatus == true {
                        if let orderId = waitTimeResult.orderId {
                            MainModel.orderId = orderId
                            finishMethod()
                        }
                        else{
                            var waitSecond = 0
                            if let waitTime = waitTimeResult.waitTime {
                                waitSecond = calcWaitSecond(waitTime)
                            }
                            else {
//                                failMethod()
                            }
                            
                            if waitSecond > 0 {
                                if waitSecond > 5 {
                                    let waitInfo = "提交订单成功,请等待\(waitSecond)秒"
                                    waitMethod(info: waitInfo)
                                }
                                sleep(UInt32(waitSecond))
                            }
                            
                            self.queryOrderWaitTime(failMethod,waitMethod: waitMethod,finishMethod: finishMethod)
                        }
                    }
                    else{
                        let error = ServiceError.errorWithCode(.ConfirmSingleForQueueFailed)
                        failMethod(error: error)
                        //maybe login again
                        //提交订单出错
                    }
                }})
    }
    
    func cancelNoCompleteOrder(sequence_no:String)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/cancelNoCompleteMyOrder"
            let params = [
                "sequence_no":sequence_no,
                "cancel_flag":"cancel_order",
                "_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let json = JSON(data)
                    logger.debug("\(json)")
                    fulfill()
                }})
        }
    }
    
}
