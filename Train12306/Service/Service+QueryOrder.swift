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

extension Service{
    
    func queryHistoryOrderFlow(success success:()->(), failure:()->()){
        var promise = self.queryOrderInit().then({()->Promise<Int> in
            MainModel.historyOrderList.removeAll()
            return self.queryMyOrderWithPageIndex(0)
        })
        
        promise.then({ totalNum -> Promise<Int> in
            let count = (totalNum - 1) / 8
            if count > 0 {
                for i in 1...count{
                    promise = promise.then({_ -> Promise<Int> in self.queryMyOrderWithPageIndex(i)})
                }
            }
            return promise
        }).then({_ in
            success()
        }).error({_ in
            failure()
        })
    }
    
    func queryOrderInit()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/init"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/index/initMy12306"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func queryMyOrderWithPageIndex(index:Int)->Promise<Int>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrder"
            var params = QueryOrderParam()
            params.pageIndex = index
            
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/init"]
            Service.Manager.request(.POST, url, parameters: params.ToPostParams(), headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let jsonData = JSON(data)["data"]
                    guard jsonData["OrderDTODataList"].count > 0 else {
                        print("queryMyOrder:\(jsonData)")
                        reject(NSError(domain: "queryMyOrderWithPageIndex:", code: 0, userInfo: nil))
                        return
                    }
                    let total = jsonData["order_total_number"].string
                    let num = jsonData["OrderDTODataList"].count
                    for i in 0...num-1 {
                        MainModel.historyOrderList.append(OrderDTOData(jsonData:jsonData["OrderDTODataList"][i]))
                    }
                    fulfill(Int(total!)!)
            }})
        }
    }
    
    func queryNoCompleteOrderFlow(success success:()->(), failure:()->()){
        
        self.queryOrderInitNoComplete().then({() -> Promise<String> in
            return self.queryMyOrderNoComplete()
        }).then({_ in
            success()
        }).error({_ in
            failure()
        })
    }
    
    func queryOrderInitNoComplete()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/index/initMy12306"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseString(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func queryMyOrderNoComplete()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrderNoComplete"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let orderDBList = JSON(data)["data"]["orderDBList"]
                    if orderDBList.count > 0{
                        for i in 0...orderDBList.count - 1 {
                            MainModel.noCompleteOrderList.append(OrderDTOData(jsonData:orderDBList[i]))
                        }
                    }
                    fulfill(url)
            }})
        }
    }
    
}
