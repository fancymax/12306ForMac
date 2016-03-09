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
    
// MARK: - Request Flow
    func queryTicketFlowWith(params:LeftTicketParam,success:(tickets:[QueryLeftNewDTO])->(),failure:(error:NSError)->())
    {
        var queryLog = false
        var queryUrl = ""
        
        self.queryTicketInit().then({(isQueryLog,leftUrl,jsName) -> Promise<Void> in
            queryLog = isQueryLog
            queryUrl = leftUrl
            return self.requestDynamicJs(jsName, referHeader: ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"])
        }).then({()->Promise<Void> in
            return self.queryTicketLogWith(params,isQueryLog: queryLog)
        }).then({_ -> Promise<[QueryLeftNewDTO]> in
            return self.queryTicketWith(params,queryUrl: queryUrl)
        }).then({tickets in
            success(tickets: tickets)
        }).error({error  in
            failure(error: error as NSError)
        })
    }
    
// MARK: - Chainable Request
    func queryTicketInit()->Promise<(Bool,String,String)>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/leftTicket/init"
            Service.Manager.request(.GET, url).responseString(completionHandler:{ response in
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
    
    func queryTicketLogWith(params:LeftTicketParam,isQueryLog:Bool)->Promise<Void>{
        return Promise{ fulfill, reject in
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            if isQueryLog {
                let url = "https://kyfw.12306.cn/otn/leftTicket/log?" + params.ToGetParams()
                Service.Manager.request(.GET, url, headers:headers).responseString(completionHandler:{response in
                })
            }
            
            fulfill()
            
        }
    }
    
    func queryTicketWith(params:LeftTicketParam,queryUrl:String)->Promise<[QueryLeftNewDTO]>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/" + queryUrl + "?" + params.ToGetParams()
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            Service.Manager.request(.GET, url, headers: headers).responseJSON(completionHandler:{ response in
                    switch (response.result){
                    case .Failure(let error):
                        reject(error)
                    case .Success(let data):
                        let json = JSON(data)["data"]
                        if json.count > 0 {
                            var tickets = [QueryLeftNewDTO]()
                            for i in 0..<json.count
                            {
                                let leftTicket = QueryLeftNewDTO(json: json[i])
                                tickets.append(leftTicket)
                            }
                            fulfill(tickets)
                        }
                        else{
                            let failureReason = "未能查到任何车次,请检查查询设置"
                            let error = ServiceError.errorWithCode(.QueryTicketFailed, failureReason: failureReason)
                            reject(error)
                        }
                    }
                })}
    }
    
}