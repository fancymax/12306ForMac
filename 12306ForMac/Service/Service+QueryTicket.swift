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
    func queryTicketFlowWith(_ params:LeftTicketParam,success:@escaping ([QueryLeftNewDTO])->Void,failure:@escaping (NSError)->Void)
    {
        var queryLog = false
        var queryUrl = ""
        
        self.queryTicketInit().then{(isQueryLog,leftUrl,jsName) -> Promise<Void> in
            queryLog = isQueryLog
            queryUrl = leftUrl
            return self.requestDynamicJs(jsName, referHeader: ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"])
        }.then{()->Promise<Void> in
            return self.queryTicketLogWith(params,isQueryLog: queryLog)
        }.then{_ -> Promise<[QueryLeftNewDTO]> in
            return self.queryTicketWith(params,queryUrl: queryUrl)
        }.then{tickets in
            success(tickets)
        }.catch{error  in
            failure(error as NSError)
        }
    }
    
    func queryTrainDetailFlowWith(_ params:QueryByTrainCodeParam,success:@escaping (TrainCodeDetails)->Void,failure:@escaping (NSError)->Void) {
        self.queryByTrainNo(params).then{trainCodeDetails in
            success(trainCodeDetails)
        }.catch {error in
            failure(error as NSError)
        }
    }
    
    func queryTrainPriceFlowWith(_ params:QueryTrainPriceParam,success:@escaping (TrainPrice)->Void,failure:@escaping (NSError)->Void) {
        self.queryTicketPrice(params).then{trainPrice in
            success(trainPrice)
        }.catch {error in
            failure(error as NSError)
        }
    }
    
// MARK: - Chainable Request
    func queryTicketInit()->Promise<(Bool,String,String)>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/leftTicket/init"
            Service.Manager.request(url).responseString(completionHandler:{ response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let content):
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
    
    func queryTicketLogWith(_ params:LeftTicketParam,isQueryLog:Bool)->Promise<Void>{
        return Promise{ fulfill, reject in
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            if isQueryLog {
                let url = "https://kyfw.12306.cn/otn/leftTicket/log?" + params.ToGetParams()
                Service.Manager.request(url, headers:headers).responseString(completionHandler:{response in
                })
            }
            
            fulfill()
            
        }
    }
    
    func queryTicketWith(_ params:LeftTicketParam,queryUrl:String)->Promise<[QueryLeftNewDTO]>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/" + queryUrl + "?" + params.ToGetParams()
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            Service.Manager.request(url, headers: headers).responseJSON(completionHandler:{ response in
                    switch (response.result){
                    case .failure(let error):
                        reject(error)
                    case .success(let data):
                        let json = JSON(data)["data"]
                        if json.count > 0 {
                            var tickets = [QueryLeftNewDTO]()
                            for i in 0..<json.count
                            {
                                let leftTicket = QueryLeftNewDTO(json: json[i],dateStr: params.train_date)
                                tickets.append(leftTicket)
                            }
                            fulfill(tickets)
                        }
                        else{
                            let error:NSError
                            let jsonMessage = JSON(data)["messages"]
                            if jsonMessage.count != 0 {
                                if let errorMessage = jsonMessage[0].string {
                                    error = ServiceError.errorWithCode(.queryTicketFailed, failureReason: errorMessage)
                                }
                                else {
                                    error = ServiceError.errorWithCode(.queryTicketFailed)
                                }
                            }
                            else {
                                error = ServiceError.errorWithCode(.queryTicketFailed)
                            }
                            reject(error)
                        }
                    }
                })}
    }
    
    //https://kyfw.12306.cn/otn/czxx/queryByTrainNo?train_no=6i000D232806&from_station_telecode=IOQ&to_station_telecode=FYS&depart_date=2016-06-12
    func queryByTrainNo(_ params: QueryByTrainCodeParam)->Promise<TrainCodeDetails>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/czxx/queryByTrainNo?" + params.ToGetParams()
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            Service.Manager.request(url, headers: headers).responseJSON(completionHandler:{ response in
                    switch (response.result){
                    case .failure(let error):
                        reject(error)
                    case .success(let data):
                        let json = JSON(data)["data"]["data"]
                        if json.count > 0 {
                            let trainCodeDetails = TrainCodeDetails(json: json)
                            fulfill(trainCodeDetails)
                        }
                        else  {
                            let error = ServiceError.errorWithCode(.queryTicketFailed)
                            reject(error)
                            
                        }
                    }
                })}
    }
    
    func queryTicketPrice(_ params:QueryTrainPriceParam)->Promise<TrainPrice> {
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/leftTicket/queryTicketPrice?" + params.ToGetParams()
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init",
                           "If-Modified-Since":"0",
                           "Cache-Control":"no-cache"]
            Service.Manager.request(url, headers: headers).responseJSON(completionHandler:{ response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let json = JSON(data)["data"]
                    let trainPrice = TrainPrice(json: json)
                    fulfill(trainPrice)
                }
            })}
    }
    
}
