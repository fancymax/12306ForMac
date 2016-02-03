//
//  PcHTTPService+Order.swift
//  Train12306
//
//  Created by fancymax on 15/11/8.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

extension HTTPService{
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
    
    func postMobileGetPassengerDTOs(successHandler:()->())
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let jsonData = JSON(responseObject)["data"]
                guard jsonData["normal_passengers"].count > 0 else {
                    print("getPassengerDTOsForPC:\(jsonData)")
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
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
        })
    }
    
    func getPreOrderImage(successHandler:(image:NSImage) -> (),failHandler:()->()){
        let cancelOperations = {
            self.shareHTTPManager.operationQueue.cancelAllOperations()
        }
        
        //这里逻辑有问题
        let checkUserOperation = checkUserForPC({}, failHandler: cancelOperations)
        let submitOrderOperation = submitOrderRequestForPC({}, failHandler: cancelOperations)
        let initDCOperation = initDC({}, failHandler: cancelOperations)
        let getImageOperation = getPassCodeNewForPassenger(successHandler: successHandler,failHandler: failHandler)
        
        submitOrderOperation.addDependency(checkUserOperation)
        initDCOperation.addDependency(submitOrderOperation)
        getImageOperation.addDependency(initDCOperation)
        
        shareHTTPManager.operationQueue.addOperations([checkUserOperation,submitOrderOperation,initDCOperation,getImageOperation], waitUntilFinished: false)
    }
    
    func checkUserForPC(successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/login/checkUser"
        let params = ["_json_att":""]
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                guard JSON(responseObject)["data"]["flag"].bool == true else {
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
            })!
    }
    
    func submitOrderRequestForPC(successHandler :()->(),failHandler: ()->())->AFHTTPRequestOperation
    {
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
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                guard JSON(responseObject)["data"].string == "Y" else {
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
            })!
    }
    
    func initDC(successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/initDc"
        let params = ["_json_att":""]
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFHTTPResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let content = NSString(data: (responseObject as! NSData), encoding: NSUTF8StringEncoding) as? String
                {
//                    Swift.print("request Header:\(self.shareHTTPManager.requestSerializer.HTTPRequestHeaders)")
//                    Swift.print("response Header:\(operation.response?.allHeaderFields)")
                    //var globalRepeatSubmitToken = '0effecee973601696dc68b09bfc1329c';
                    if let matches = Regex("var globalRepeatSubmitToken = '([^']+)'").getMatches(content){
                        MainModel.globalRepeatSubmitToken = matches[0][0]
                        logger.debug("globalRepeatSubmitToken = \(MainModel.globalRepeatSubmitToken!)")
                        self.getPassengerDTOsForPC({}, failHandler: {})
                    }
                    //'key_check_isChange':'EC438B8EA94EB69E378B7C951CB1B21A128F3F96F374AE6692BE5001'
                    if let matches = Regex("'key_check_isChange':'([^']+)'").getMatches(content){
                        MainModel.key_check_isChange = matches[0][0]
                        logger.debug("key_check_isChange = \(MainModel.key_check_isChange!)")
                    }
                    else{
                        logger.error("fail to get key_check_isChange:\(content)")
                        return
                    }
                    //'train_location':''
                    if let matches = Regex("'train_location':'([^']+)'").getMatches(content){
                        MainModel.train_location = matches[0][0]
                        logger.debug("train_location = \(MainModel.train_location!)")
                    }
                    else{
                        logger.error("fail to get train_location:\(content)")
                        return
                    }
                    
                    if let matches = Regex("'ypInfoDetail':'([^']+)'").getMatches(content){
                        MainModel.ypInfoDetail = matches[0][0]
                        logger.debug("ypInfoDetail = \(MainModel.ypInfoDetail!)")
                    }
                    else{
                        logger.error("fail to get ypInfoDetail:\(content)")
                        return
                    }
                }
                else
                {
                    logger.error("initDCForPC content nil")
                    failHandler()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            })!
    }
    
    //此功能要依靠initDC 获取 globalRepeatSubmitToken,所以和它连一起
    func getPassengerDTOsForPC(successHandler:()->(),failHandler:()->())
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
        let params = ["_json_att":"","REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let jsonData = JSON(responseObject)["data"]
                guard jsonData["normal_passengers"].count > 0 else {
                    logger.error("\(jsonData)")
                    failHandler()
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
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
        })
    }
    
    func getPassCodeNewForPassenger(successHandler handle:(loadImage:NSImage)->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=passenger&rand=randp&0.21980984136462212"
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFImageResponseSerializer()
        return shareHTTPManager.OperationForGET(url,parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let image = responseObject as? NSImage
                {
                    handle(loadImage: image)
                }
                else
                {
                    logger.error("image = nil?")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
            }
        )!
    }
    
    func order(randCodeStr:String,successHandler:()->(),failHandler:()->()){
        let failHandlerWrapper = {
            self.shareHTTPManager.operationQueue.cancelAllOperations()
        }
        
        let checkCodeOperation = checkRandCodeAnsynForPassenger(randCodeStr, successHandler: {}, failHandler: failHandlerWrapper)
        let checkOrderOperation = checkOrderInfoForPC(randCodeStr, successHandler: {}, failHandler: failHandlerWrapper)
        let getQueueOperation = getQueueCountForPC()
        let delayOperation = NSBlockOperation(block: {sleep(1)})
        let confirmOperation = confirmSingleForQueueForPC(randCodeStr, successHandler: {}, failHandler: failHandlerWrapper)
        let delayOperation1 = NSBlockOperation(block: {sleep(1)})
        let queryOperation1 = queryOrderWaitTimeForPC({}, failHandler: failHandlerWrapper)
        let delayOperation2 = NSBlockOperation(block: {sleep(1)})
        let queryOperation2 = queryOrderWaitTimeForPC(successHandler, failHandler: failHandler)
        
        
        checkOrderOperation.addDependency(checkCodeOperation)
        getQueueOperation.addDependency(checkOrderOperation)
        delayOperation.addDependency(getQueueOperation)
        confirmOperation.addDependency(delayOperation)
        
        delayOperation1.addDependency(confirmOperation)
        queryOperation1.addDependency(delayOperation1)
        delayOperation2.addDependency(queryOperation1)
        queryOperation2.addDependency(delayOperation2)
        
        shareHTTPManager.operationQueue.addOperations([checkCodeOperation,checkOrderOperation,getQueueOperation,delayOperation,confirmOperation,delayOperation1,delayOperation2,queryOperation1,queryOperation2], waitUntilFinished: false)
    }
    
    func checkRandCodeAnsynForPassenger(randCodeStr:String,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
        let params = [
            "randCode":randCodeStr,
            "rand":"randp",
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
        
        setReferInitDC()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                guard JSON(responseObject)["data"]["result"].string == "1" else {
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            })!
    }
    
    func checkOrderInfoForPC(randCode:String,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/checkOrderInfo"
        let (passengerTicketStr,oldPassengerStr) = getPassengerStr(MainModel.passengers)
        
        let params = [
            "cancel_flag":"2",
            "bed_level_order_num":"000000000000000000000000000000",
            "passengerTicketStr":passengerTicketStr,
            "oldPassengerStr":oldPassengerStr,
            "tour_flag":"dc",
            "randCode":randCode,
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
        
        setReferInitDC()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                guard JSON(responseObject)["data"]["submitStatus"].bool == true else{
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
            })!
    }
    
    func getQueueCountForPC()->AFHTTPRequestOperation
    {
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
        
        setReferInitDC()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let json = JSON(responseObject)
                logger.debug("\(json)")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            })!
    }
    
    func confirmSingleForQueueForPC(randCode:String,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/confirmSingleForQueue"
        let (passengerTicketStr,oldPassengerStr) = getPassengerStr(MainModel.passengers)
        let params = [
            "passengerTicketStr":passengerTicketStr,
            "oldPassengerStr":oldPassengerStr,
            "randCode":randCode,
            "purpose_codes":"00",
            "key_check_isChange":MainModel.key_check_isChange!,
            "leftTicketStr":MainModel.selectedTicket!.yp_info!,
            "train_location":MainModel.train_location!,
            "roomType":"00",
            "dwAll":"N",
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":MainModel.globalRepeatSubmitToken!]
       
        setReferInitDC()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                guard JSON(responseObject)["data"]["submitStatus"].bool == true else {
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
                logger.debug("confirmSingleForQueueForPC submitStatus: true")
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            })!
    }
    
    //--查询结果--
    func queryOrderWaitTimeForPC(successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/queryOrderWaitTime?"
        let params = "random=1446560572126&tourFlag=dc&_json_att=&REPEAT_SUBMIT_TOKEN=\(MainModel.globalRepeatSubmitToken!)"
        
        setReferInitDC()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForGET(url+params,parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                guard let orderId = JSON(responseObject)["data"]["orderId"].string else{
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
                MainModel.orderId = orderId
                logger.debug(orderId)
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            })!
    }
}
