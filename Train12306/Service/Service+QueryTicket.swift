//
//  MobileTicketQueryService.swift
//  Train12306
//
//  Created by fancymax on 15/10/24.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

extension Service {
    
    func queryTicketFlowWith(params:LeftTicketParam,success:(tickets:[QueryLeftNewDTO])->(),failure:()->())
    {
        var queryLog = false
        var queryUrl = ""
        var dynamicJs = ""
        
        self.queryTicketInit().then({(isQueryLog,leftUrl,jsName) -> Promise<String> in
            queryLog = isQueryLog
            queryUrl = leftUrl
            dynamicJs = jsName
            return self.queryTicketLogWith(params,isQueryLog: queryLog)
        }).then({_ -> Promise<[QueryLeftNewDTO]> in
            print("queryLog = \(queryLog) queryUrl= \(queryUrl) dynamicJs = \(dynamicJs)")
            return self.queryTicketWith(params,queryUrl: queryUrl)
        }).then({tickets in
            success(tickets: tickets)
        }).error({_ in
            failure()
        })
    }
    
    func queryTicketInit()->Promise<(Bool,String,String)>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/leftTicket/init"
            Service.Manager1.request(.GET, url).responseString(completionHandler:{ response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let content):
                    var cLeftTicketUrl:String = "leftTicket/queryT"
                    if let matches = Regex("var CLeftTicketUrl = '([^']+)'").getMatches(content){
                        cLeftTicketUrl = matches[0][0]
                    }
                    else{
                        logger.error("fail to get CLeftTicketUrl:\(content)")
                    }
                
                    // var isSaveQueryLog='Y';
                    var isSaveQueryLog = true
                    if let matches = Regex("var isSaveQueryLog='([^']+)'").getMatches(content){
                        let isSaveQueryLogStr = matches[0][0]
                        if isSaveQueryLogStr == "Y" {
                            isSaveQueryLog = true
                        }
                        else{
                            isSaveQueryLog = false
                        }
                    }
                    else{
                        logger.error("fail to get isSaveQueryLog:\(content)")
                    }
                    
                    // src="/otn/dynamicJs/qdrtdtw"
                    var dynamicJs = ""
                    if let matches = Regex("src=\"/otn/dynamicJs/([^\"]+)\"").getMatches(content){
                        dynamicJs = matches[0][0]
                        logger.debug("dynamicJs = \(dynamicJs)")
                    }
                    else{
                        logger.error("fail to get dynamicJs:\(content)")
                    }
                    
                    let isQueryLog = isSaveQueryLog
                    let leftUrl = cLeftTicketUrl
                    let jsName = dynamicJs
                    fulfill(isQueryLog,leftUrl,jsName)
                }})}
    }
    
    func queryTicketLogWith(params:LeftTicketParam,isQueryLog:Bool)->Promise<String>{
        return Promise{ fulfill, reject in
            if isQueryLog {
                let url = "https://kyfw.12306.cn/otn/leftTicket/log?" + params.ToGetParams()
                Service.Manager1.request(.GET, url).responseString(completionHandler:{_ in })
            }
            fulfill("Always Succeed")
        }
    }
    
    func queryTicketWith(params:LeftTicketParam,queryUrl:String)->Promise<[QueryLeftNewDTO]>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/" + queryUrl + "?" + params.ToGetParams()
            Service.Manager1.request(.GET, url).responseJSON(completionHandler:{ response in
                    switch (response.result){
                    case .Failure(let error):
                        reject(error)
                    case .Success(let data):
                        let jsonData = JSON(data)["data"]
                        var tickets = [QueryLeftNewDTO]()
                        for i in 0..<jsonData.count
                        {
                            let leftTicket = QueryLeftNewDTO(jsonData: jsonData[i])
                            tickets.append(leftTicket)
                        }
                        fulfill(tickets)
                    }
                })}
    }
    
}