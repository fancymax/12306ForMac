//
//  MobileTicketQueryService.swift
//  Train12306
//
//  Created by fancymax on 15/10/24.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

extension HTTPService {
    
    func getTicket(leftTicketDTO:LeftTicketDTO,successHandler:()->(),failHandler:()->())
    {
        let initOperation = getLeftTicketInit()
        let logOperation = getLeftTicketLog(leftTicketDTO, successHandler: {}, failHandler: failHandler)
        let queryOperation = getLeftTicketQuery(leftTicketDTO, successHandler: successHandler, failHandler: failHandler)
        queryOperation.addDependency(logOperation)
        logOperation.addDependency(initOperation)
        //开始运行
        shareHTTPManager.operationQueue.addOperations([initOperation,logOperation,queryOperation], waitUntilFinished: false)
    }
    
    //leftTicket/init
    func getLeftTicketInit()->AFHTTPRequestOperation
    {
        shareHTTPManager.responseSerializer = AFHTTPResponseSerializer()
        return shareHTTPManager.OperationForGET(
            "https://kyfw.12306.cn/otn/leftTicket/init",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            }
        )!
    }
    
    func getLeftTicketLog(leftTicketDTO:LeftTicketDTO,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation{
        let queryParam = "leftTicketDTO.train_date=\(leftTicketDTO.train_date!)&leftTicketDTO.from_station=\(leftTicketDTO.from_station!)&leftTicketDTO.to_station=\(leftTicketDTO.to_station!)&purpose_codes=\(leftTicketDTO.purpose_codes!)"
        let url = "https://kyfw.12306.cn/otn/leftTicket/log?" + queryParam
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForGET(url, parameters: nil,
            success: {(operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                Swift.print(self.shareHTTPManager.requestSerializer.HTTPRequestHeaders)
                Swift.print("response Header:\(operation.response?.allHeaderFields)")
                
                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
                let cookieStr = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
                self.shareHTTPManager.requestSerializer.setValue(cookieStr["Cookie"], forHTTPHeaderField:"Cookie")
                
                print("url cookies str = \(cookieStr)")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            }
        )!
    }
    
    func getLeftTicketQuery(leftTicketDTO:LeftTicketDTO,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation{
        let queryParam = "leftTicketDTO.train_date=\(leftTicketDTO.train_date!)&leftTicketDTO.from_station=\(leftTicketDTO.from_station!)&leftTicketDTO.to_station=\(leftTicketDTO.to_station!)&purpose_codes=\(leftTicketDTO.purpose_codes!)"
        let url = "https://kyfw.12306.cn/otn/leftTicket/queryT?" + queryParam
        
        setReferLeftTicketInit()
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        return shareHTTPManager.OperationForGET(url, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let jsonData = JSON(responseObject)["data"]
                guard jsonData.count > 0 else {
                    logger.error(jsonData.stringValue)
                    failHandler()
                    return
                }
                MainModel.leftTickets = [QueryLeftNewDTO]()
                for i in 0..<jsonData.count
                {
                    let leftTicket = QueryLeftNewDTO(jsonData: jsonData[i])
                    MainModel.leftTickets!.append(leftTicket)
                }
                successHandler()
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            }
        )!
    }

}