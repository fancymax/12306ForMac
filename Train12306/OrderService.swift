//
//  OrderService.swift
//  Train12306
//
//  Created by fancymax on 15/8/26.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

extension HTTPService{
    
    func checkRandCodeAnsyn(trainInfo:QueryLeftNewDTO,passengers:[PassengerDTO],randCodeStr:String)
    {
        let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
        var params = ["randCode":randCodeStr,
            "rand":"randp",
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":HTTPService.token]
        println("token = \(HTTPService.token)")
        
        
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let result = json["data"]["result"].string,
                        let msg = json["data"]["msg"].string {
                        println("checkRandCodeAnsyn->result:\(result),msg:\(msg)")
                            self.postCheckOrderInfo(trainInfo, passengers: passengers, randCode: randCodeStr)
                    }
                    else{
                        println("checkRandCodeAnsyn->result:nil,msg:nil")
                    }
                }
                else
                {
                    println("content nil")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    
    func postCheckOrderInfo(trainInfo:QueryLeftNewDTO,passengers:[PassengerDTO],randCode:String)
    {
        let cancel_flag="2";
        let bed_level_order_num = "000000000000000000000000000000";
        let tour_flag = "dc"
        var i = 0;
        var passengerTicketStr = ""
        var oldPassengerStr = ""
        for passenger in passengers {
            //如果是自动提交,需要把这里的Passenger_name进行url编码  System.Web.HttpUtility.UrlEncode
//            1,0,1,阿飞,1,152326196602010090,13522222222,N_1,0,1,啊啊,1,610104196212028315,,N
            var onePassengerStr = "\(passenger.seatCode),\(passenger.passenger_flag!),\(passenger.ticketCode),\(passenger.passenger_name!),\(passenger.passenger_id_type_code!),\(passenger.passenger_id_no!),\(passenger.mobile_no!),N"
            
           // if (i+1 > passengers.count) {
                passengerTicketStr = passengerTicketStr + onePassengerStr
            //}
            //else{
             //   passengerTicketStr = passengerTicketStr + onePassengerStr + "_"
            //}
            
            //阿飞,1,152326198802010090,1_啊啊,1,610104196212028315,1_
            oldPassengerStr = oldPassengerStr + "\(passenger.passenger_name!),\(passenger.passenger_id_type_code!),\(passenger.passenger_id_no!),\(passenger.ticketCode)_"
            
            break
            
            i++
        }
        passengerTicketStr = "O,0,1,林大海,1,350125198905120314,18676768751,N"
        oldPassengerStr = "林大海,1,350125198905120314,1_"
        
        println("cancel_flag = \(cancel_flag)")
        println("bed_level_order_num = \(bed_level_order_num)")
        println("passengerTicketStr = \(passengerTicketStr)")
        println("oldPassengerStr = \(oldPassengerStr)")
        println("tour_flag = \(tour_flag)")
        println("randCode = \(randCode)")
        println("token = \(HTTPService.token)")
        
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/checkOrderInfo"
        
        var params = ["cancel_flag":cancel_flag,
            "bed_level_order_num":bed_level_order_num,
            "passengerTicketStr":passengerTicketStr,
            "oldPassengerStr":oldPassengerStr,
            "tour_flag":tour_flag,
            "randCode":randCode,
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":HTTPService.token]
        
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let submitStatus = json["data"]["submitStatus"].bool {
                        println("submitStatus:\(submitStatus)")
                        self.postGetQueueCount(trainInfo)
                    }
                    else{
                        println("submitStatus:nil")
                    }
                    if let smokeStr = json["data"]["smokeStr"].string{
                        println("smokeStr = \(smokeStr)")
                    }
                }
                else
                {
                    println("content nil")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
        
    }
    
    func postGetQueueCount(trainInfo: QueryLeftNewDTO)
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/getQueueCount"
        
//        var dateFormatStr = "EEE+MMM+dd+yyyy+HH:mm:ss+'GMT'+'0800'+('CST')"
//        var local = NSLocale(localeIdentifier: "en-US")
//        var dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = dateFormatStr
//        dateFormatter.locale = local
//        let train_date = dateFormatter.stringFromDate(trainInfo.startTrainDate!)
        
        let train_date = "Wed+Sep+23+2015+00:00:00+GMT+0800+(CST)"
        
        
        var params = ["train_date":train_date,
            "train_no":trainInfo.train_no!,
            "stationTrainCode":trainInfo.TrainCode!,
            "seatType":"O",
            "fromStationTelecode":trainInfo.FromStationCode!,
            "toStationTelecode":trainInfo.ToStationCode!,
            "leftTicket":trainInfo.yp_info!,
            "purpose_codes":"00",
            "_json_att":"",
            "REPEAT_SUBMIT_TOKEN":HTTPService.token]
        
        println("trainno = \(trainInfo.train_no!)")
        println("stationTrainCode = \(trainInfo.TrainCode!)")
        println("fromStationCode = \(trainInfo.FromStationCode!)")
        println("toStationCode = \(trainInfo.ToStationCode!)")
        println("leftticket = \(trainInfo.yp_info!)")
        
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let result = json["data"]["ticket"].string{
                        println("postQueueCount->ticket:\(result)")
                    }
                    else{
                        println("postQueueCount->ticket:nil")
                    }
                }
                else
                {
                    println("content nil")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
}
