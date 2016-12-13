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
    func submitFlow(_ params:SubmitOrderParams,success:@escaping ()->Void,failure:@escaping (NSError)->Void){
        self.checkUser().then{() ->Promise<Void> in
            return self.submitOrderRequest(params)
        }.then{_ in
            self.initDC()
        }.then{jsName->Promise<Void> in
            return self.requestDynamicJs(jsName, referHeader: ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"])
        }.then{_ in
            success()
        }.catch{error in
            failure(error as NSError)
        }
    }
    
    func preOrderFlow(success:@escaping (NSImage)->Void,failure: @escaping (NSError)->Void){
        self.getPassengerDTOs().then{_ -> Promise<NSImage> in
            return self.getPassCodeNewForPassenger()
        }.then{image in
            success(image)
        }.catch{error in
            failure(error as NSError)
        }
    }
    
    func checkOrderFlow(success:@escaping (_ ifShowRandCode: Bool)->Void,failure:@escaping (NSError)->Void) {
        self.checkOrderInfo("").then{ifshowRandCode in
            success(ifshowRandCode)
        }.catch{error in
            failure(error as NSError)
        }
    }
    
    func orderFlowWithoutRandCode(success:@escaping ()->Void,failure:@escaping (NSError)->Void,wait:@escaping (String)->Void){
            let randCodeStr = ""
            self.checkOrderInfo(randCodeStr).then{_ -> Promise<Void> in
                return self.getQueueCount(wait)
            }.then{_ -> Promise<Void> in
                return after(interval: 1)
            }.then{_ -> Promise<Void> in
                return self.confirmSingleForQueue(randCodeStr)
            }.then{
                self.queryOrderWaitTime(failure, waitMethod: wait, finishMethod: success)
            }.catch{error in
                failure(error as NSError)
        }
    }

    func orderFlowWith(_ randCodeStr:String,success:@escaping ()->Void,failure:@escaping (NSError)->Void,wait:@escaping (String)->Void){
        self.checkRandCodeForOrder(randCodeStr).then{_ -> Promise<Bool> in
            return self.checkOrderInfo(randCodeStr)
        }.then{_ -> Promise<Void> in
            return self.getQueueCount(wait)
        }.then{_ -> Promise<Void> in
            return after(interval: 1)
        }.then{_ -> Promise<Void> in
            return self.confirmSingleForQueue(randCodeStr)
        }.then{
            self.queryOrderWaitTime(failure, waitMethod: wait, finishMethod: success)
        }.catch{error in
            failure(error as NSError)
        }
    }
    
    func cancelOrderWith(_ sequence_no:String,success:@escaping ()->Void,failure:@escaping (NSError)->Void){
        self.queryOrderInitNoComplete().then{() -> Promise<Void> in
            return self.queryMyOrderNoComplete()
        }.then{() -> Promise<Void> in
            self.cancelNoCompleteOrder(sequence_no)
        }.then{
            success()
        }.catch{error in
            failure(error as NSError)
        }
    }
    
    internal func getPassengerStr(_ passengers:[PassengerDTO]) ->(String,String){
        var passengerStr = ""
        var oldPassengerStr = ""
        var i = 0
        for p in passengers {
            if p.isChecked{
                passengerStr += "\(p.seatCode),0,\(p.passenger_type),\(p.passenger_name),\(p.passenger_id_type_code),\(p.passenger_id_no),\(p.mobile_no!),N"
                
                oldPassengerStr += "\(p.passenger_name),\(p.passenger_id_type_code),\(p.passenger_id_no),\(p.passenger_type)_"
                
                if i+1 < passengers.count{
                    passengerStr += "_"
                }
            }
            i += 1
        }
        return (passengerStr,oldPassengerStr)
    }
    
// MARK: - Chainable Request
    func checkUser()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/checkUser"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if JSON(data)["data"]["flag"].bool == true{
                        fulfill()
                    }else {
                        let error = ServiceError.errorWithCode(.checkUserFailed)
                        reject(error)
                    }
                }})
        }
    }
    
    func submitOrderRequest(_ params:SubmitOrderParams)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/leftTicket/submitOrderRequest"

            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(url, method:.post, parameters: params.ToPostParams(), headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let isTrue = JSON(data)["status"].bool , isTrue{
                        fulfill()
                    }
                    else {
                        logger.error("params:\(params)")
                        logger.error("JSON:\(JSON(data))")
                        let error:NSError
                        if let message = JSON(data)["messages"][0].string{
                            error = ServiceError.errorWithCode(.submitOrderFailed, failureReason: message)
                        }
                        else{
                            error = ServiceError.errorWithCode(.submitOrderFailed)
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
            Service.Manager.request(url,method:.post, parameters: params, headers:headers).responseString(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let content):
                    if let matches = Regex("var globalRepeatSubmitToken = '([^']+)'").getMatches(content){
                        MainModel.globalRepeatSubmitToken = matches[0][0]
                    }
                    else{
                        logger.error("fail to get globalRepeatSubmitToken:\(content)")
                    }
                    
                    var dynamicJs = ""
                    if let matches = Regex("src=\"/otn/dynamicJs/([^\"]+)\"").getMatches(content){
                        dynamicJs = matches[0][0]
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
                    
                    if let matches = Regex(",'train_date':'([^']+)',").getMatches(content){
                        MainModel.trainDate = matches[0][0]
                    }
                    else{
                        logger.error("fail to get trainDate:\(content)")
                    }
                    
                    fulfill(dynamicJs)
                }})
        }
    }
    
    func getPassengerDTOs(isSubmit:Bool = true)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
            let params:[String:String]
            let headers:[String:String]
            if !isSubmit {
                params = ["_json_att":""]
                headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            }
            else {
                params = ["_json_att":"","REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
                headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            }
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let json = JSON(data)["data"]
                    if json["normal_passengers"].count == 0 {
                        logger.error("\(json)")
                        let error:NSError
                        if let errorMsg = json["exMsg"].string {
                            error = ServiceError.errorWithCode(.getPassengerFailed, failureReason: errorMsg)
                        }
                        else {
                            error = ServiceError.errorWithCode(.getPassengerFailed)
                        }
                        reject(error)
                        return
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
            Service.Manager.request(url, headers:headers).responseData{ response in
                switch (response.result){
                    case .failure(let error):
                        reject(error)
                    case .success(let data):
                        if let image = NSImage(data: data){
                            fulfill(image)
                        }
                        else{
                            let error = ServiceError.errorWithCode(.getRandCodeFailed)
                            reject(error)
                        }
                }}
        }
    }
    
    func checkRandCodeForOrder(_ randCodeStr:String) ->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
            let params = [
                "randCode":randCodeStr,
                "rand":"randp",
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if JSON(data)["data"]["result"].string == "1"{
                        fulfill()
                    }
                    else {
                        logger.error("\(JSON(data))")
                        let error = ServiceError.errorWithCode(.checkRandCodeFailed)
                        reject(error)
                    }
                }})
        }
    }
    
    func checkOrderInfo(_ randCodeStr:String)->Promise<Bool>{
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
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if JSON(data)["data"]["submitStatus"].bool == true{
                        if let ifShowPassCode = JSON(data)["data"]["ifShowPassCode"].bool {
                            fulfill(ifShowPassCode)
                        }
                        else {
                            fulfill(false)
                        }
                    }else{
                        logger.error("\(JSON(data))")
                        if let errMsg = JSON(data)["data"]["errMsg"].string {
                            reject(ServiceError.errorWithCode(.checkOrderInfoFailed,failureReason: errMsg))
                        }
                        else{
                            reject(ServiceError.errorWithCode(.checkOrderInfoFailed))
                        }
                    }
                }})
        }
    }
    
    func getQueueCount(_ waitMethod :@escaping (_ info:String) -> ())->Promise<Void>{
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
                "train_location":MainModel.train_location!,
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let json):
                    let ticketQueueCount = TicketQueueCountResult(json:JSON(json)["data"])
                    if ticketQueueCount.shouldRelogin() {
                        reject(ServiceError.errorWithCode(.checkUserFailed))
                    }
                    let warningStr = ticketQueueCount.getWarningInfoBy(MainModel.selectPassengers[0].seatCodeName)
                    if ticketQueueCount.isTicketSoldOut() {
                        reject(ServiceError.errorWithCode(.confirmSingleForQueueFailed, failureReason: warningStr))
                    }
                    else {
                        if warningStr != "" {
                            waitMethod(warningStr) 
                        }
                        fulfill()
                    }
                }})
        }
    }
    
    func confirmSingleForQueue(_ randCodeStr:String) ->Promise<Void>{
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
                "choose_seats":"",
                "seatDetailType":"000",
                "roomType":"00",
                "dwAll":"N",
                "_json_att":"",
                "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
            let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if JSON(data)["data"]["submitStatus"].bool == true{
                        fulfill()
                    }else {
                        logger.error("\(JSON(data))")
                        let error = ServiceError.errorWithCode(.confirmSingleForQueueFailed)
                        reject(error)
                    }
                }})
        }
    }
    
    func queryOrderWaitTime(_ failMethod:@escaping (_ error:NSError)->(), waitMethod :@escaping (_ info:String) -> (),finishMethod:@escaping ()->()) {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/queryOrderWaitTime?"
        let params = "random=1446560572126&tourFlag=dc&_json_att=&REPEAT_SUBMIT_TOKEN=\(MainModel.globalRepeatSubmitToken!)"
        let headers = ["refer": "https://kyfw.12306.cn/otn/confirmPassenger/initDc"]
    
        func calcWaitSecond(_ waitTime:Int) -> Int {
            var p1 = waitTime * 2 / 3
            if p1 > 60 {
                p1 = 60
            }
            
            return p1
        }
    
        Service.Manager.request(url + params, headers:headers).responseJSON(completionHandler:{response in
            switch (response.result){
            case .failure(let error):
                logger.error(error.localizedDescription)
                failMethod(error as NSError)
            case .success(let data):
                let waitTimeResult = QueryOrderWaitTimeResult(json: JSON(data)["data"])
                
                if let submitStatus = waitTimeResult.queryOrderWaitTimeStatus , submitStatus == true {
                    if let orderId = waitTimeResult.orderId {
                        MainModel.orderId = orderId
                        finishMethod()
                    }
                    else{
                        var waitSecond = 0
                        if let waitTime = waitTimeResult.waitTime {
                            waitSecond = calcWaitSecond(waitTime)
                        
                            if waitSecond > 0 {
                                if waitSecond > 5 {
                                    let waitInfo = "提交订单成功,请等待\(waitSecond)秒"
                                    waitMethod(waitInfo)
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(waitSecond)) {
                                    self.queryOrderWaitTime(failMethod,waitMethod: waitMethod,finishMethod: finishMethod)
                                }
                                
                            }
                            else {
                                if let msg = waitTimeResult.msg {
                                    let error = ServiceError.errorWithCode(.confirmSingleForQueueFailed,failureReason: msg)
                                    failMethod(error)
                                }
                                else {
                                    let error = ServiceError.errorWithCode(.confirmSingleForQueueFailed)
                                    failMethod(error)
                                }
                            }
                        }
                        else {
                            let error = ServiceError.errorWithCode(.confirmSingleForQueueFailed)
                            failMethod(error)
                        }
                    }
                }
                else{
                    let error = ServiceError.errorWithCode(.confirmSingleForQueueFailed)
                    failMethod(error)
                    //maybe login again
                }
            }})
    }
    
    func cancelNoCompleteOrder(_ sequence_no:String)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/cancelNoCompleteMyOrder"
            let params = [
                "sequence_no":sequence_no,
                "cancel_flag":"cancel_order",
                "_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let json = JSON(data)
                    if let existError = json["data"]["existError"].string  {
                        if existError == "Y" {
                            let error = ServiceError.errorWithCode(.cancelOrderFailed)
                            reject(error)
                        }
                        else {
                            fulfill()
                        }
                    }
                    else {
                        fulfill()
                    }
                }})
        }
    }
    
}
