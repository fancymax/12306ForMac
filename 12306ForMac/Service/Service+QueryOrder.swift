//
//  Service+QueryOrder.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

extension Service{
    
    func queryHistoryOrderFlow(_ success:@escaping ()->(), failure:@escaping ()->()){
        var promise = self.queryOrderInit().then{()->Promise<Int> in
            MainModel.historyOrderList.removeAll()
            return self.queryMyOrderWithPageIndex(0)
        }
        
        promise.then{ totalNum -> Promise<Int> in
            let count = (totalNum - 1) / 8
            if count > 0 {
                for i in 1...count{
                    promise = promise.then{_ -> Promise<Int> in self.queryMyOrderWithPageIndex(i)}
                }
            }
            return promise
        }.then {_ in
            success()
        }.catch {_ in
            failure()
        }
    }
    
    func queryOrderInit()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/init"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/index/initMy12306"]
            Service.Manager.request(url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func queryMyOrderWithPageIndex(_ index:Int)->Promise<Int>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrder"
            var params = QueryOrderParam()
            params.pageIndex = index
            
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/init"]
            Service.Manager.request(url, parameters: params.ToPostParams(), headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let jsonData = JSON(data)["data"]
                    let orderDBList = JSON(data)["data"]["orderDBList"]
                    guard orderDBList.count > 0 else {
                        reject(NSError(domain: "queryMyOrderWithPageIndex:", code: 0, userInfo: nil))
                        return
                    }
                    let total = jsonData["order_total_number"].string
                    for i in 0..<orderDBList.count {
                        let ticketNum = orderDBList[i]["tickets"].count
                        for y in 0..<ticketNum {
                            MainModel.historyOrderList.append(OrderDTO(json: orderDBList[i], ticketIdx: y))
                        }
                    }
                    fulfill(Int(total!)!)
            }})
        }
    }
    
    func queryNoCompleteOrderFlow(_ success:@escaping ()->(), failure:@escaping ()->()){
        
        self.queryOrderInitNoComplete().then{() -> Promise<String> in
            return self.queryMyOrderNoComplete()
        }.then {_ in
            success()
        }.catch {_ in
            failure()
        }
    }
    
    func queryOrderInitNoComplete()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/index/initMy12306"]
            Service.Manager.request(url, parameters: params, headers:headers).responseString(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func queryMyOrderNoComplete()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrderNoComplete"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let orderDBList = JSON(data)["data"]["orderDBList"]
                    MainModel.noCompleteOrderList = [OrderDTO]()
                    if orderDBList.count > 0{
                        for i in 0..<orderDBList.count {
                            let ticketNum = orderDBList[i]["tickets"].count
                            for y in 0..<ticketNum {
                                let ticketOrder = OrderDTO(json: orderDBList[i], ticketIdx: y)
                                MainModel.noCompleteOrderList.append(ticketOrder)
                            }
                        }
                    }
                    fulfill(url)
            }})
        }
    }
    
}
