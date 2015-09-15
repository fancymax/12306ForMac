//
//  SubmitService.swift
//  Train12306
//
//  Created by fancymax on 15/8/13.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

//PreOrderService

extension HTTPService {
    
    func checkUser()
    {
        let url = "https://kyfw.12306.cn/otn/login/checkUser"
        var params = ["_json_att":""]
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let result = json["data"]["flag"].bool
                    {
                        println("flag:\(result)")
                    }
                    else
                    {
                        println("no flag")
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
    
    func submitOrder(secretStr:String,trainDate:String,backTrainDate:String,queryFromStationName:String,queryToStationName:String)
    {
        let url = "https://kyfw.12306.cn/otn/leftTicket/submitOrderRequest"
        var params = ["secretStr":secretStr,
            "train_date":trainDate,"back_train_date":backTrainDate,
            "tour_flag":"dc","purpose_codes":"ADULT",
            "query_from_station_name":queryFromStationName,"query_to_station_name":queryToStationName,
            "undefined":""]
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let result = json["data"].string
                    {
                        println("data:" + result)
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
    
    func initDC(successHandler:(passenger:[PassengerDTO])->())
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/initDc"
        
        var params = ["_json_att":""]
        shareHTTPManager.responseSerializer = AFHTTPResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if let content = NSString(data: (responseObject as! NSData), encoding: NSUTF8StringEncoding) as? String
                {
                    if let matches =
                        Regex("globalRepeatSubmitToken = '([^']+)").getMatches(content)
                        
                    {
                        var token:String?
                        for match in matches
                        {
                            println(match[0])
                            token = match[0]
                            HTTPService.token = token!
                            self.postGetPassengerDTOs(token!,successHandler: successHandler)
                        }
                    }
                    else
                    {
                        println("match fail")
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
    
    func postGetPassengerDTOs(token:String,successHandler:(passenger:[PassengerDTO])->())
    {
        let url = "https://kyfw.12306.cn/otn/confirmPassenger/getPassengerDTOs"
        var params = ["_json_att":"","REPEAT_SUBMIT_TOKEN":token]
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if responseObject != nil{
                    let json = JSON(responseObject)
                    if json["data"]["isExist"].bool! {
                        let count = json["data"]["normal_passengers"].count
                        println("\(count)")
                        var passengers = [PassengerDTO]()
                        for i in 0...count - 1{
                            let passenger = PassengerDTO(jsonData:json["data"]["normal_passengers"][i])
                            println(passenger)
                            passengers.append(passenger)
                        }
                        successHandler(passenger: passengers)
                    }
                    else
                    {
                        println("data isExit = false")
                        
                    }
                }
                else{
                    println("nil")
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
    }
    
    func loadPassengerImage(successHandler handle:(loadImage:NSImage)->())
    {
        let loginImageUrl = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=passenger&rand=randp&0.22716084984131157"
        
        shareHTTPManager.responseSerializer = AFImageResponseSerializer()
        shareHTTPManager.GET(
            loginImageUrl,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if let image = responseObject as? NSImage
                {
                    println("\(image.size.height)")
                    println("\(image.size.width)")
                    handle(loadImage: image)
                }
                else
                {
                    println("content = nil?")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
        
    }
}
