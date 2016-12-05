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
    
// MARK: - Request Flow
    func queryHistoryOrderFlow(success:@escaping ()->Void, failure:@escaping (NSError)->Void){
        self.queryOrderInit().then{()->Promise<Int> in
            MainModel.historyOrderList.removeAll()
            return self.queryMyOrderWithPageIndex(0)
        }.then{totalNum ->Promise<Int> in
            let index = 1
            if (totalNum - 1)/8 > index {
                return self.queryMyOrderWithPageIndex(index)
            }
            else {
                return Promise{fulfill, reject in fulfill(index)}
            }
        }.then{totalNum ->Promise<Int> in
            let index = 2
            if (totalNum - 1)/8 > index {
                return self.queryMyOrderWithPageIndex(index)
            }
            else {
                return Promise{fulfill, reject in fulfill(index)}
            }
        }.then{totalNum ->Promise<Int> in
            let index = 3
            if (totalNum - 1)/8 > index {
                return self.queryMyOrderWithPageIndex(index)
            }
            else {
                return Promise{fulfill, reject in fulfill(index)}
            }
        }.then{totalNum ->Promise<Int> in
            let index = 4
            if (totalNum - 1)/8 > index {
                return self.queryMyOrderWithPageIndex(index)
            }
            else {
                return Promise{fulfill, reject in fulfill(index)}
            }
        }.then{totalNum ->Promise<Int> in
            let index = 5
            if (totalNum - 1)/8 > index {
                return self.queryMyOrderWithPageIndex(index)
            }
            else {
                return Promise{fulfill, reject in fulfill(2)}
            }
        }.then{_ in
            success()
        }.catch{error in
            failure(error as NSError)
        }
    }
    
    func queryNoCompleteOrderFlow(success:@escaping ()->Void, failure:@escaping ()->Void){
        
        self.queryOrderInitNoComplete().then{() -> Promise<Void> in
            return self.queryMyOrderNoComplete()
        }.then{_ in
            success()
        }.catch {_ in
            failure()
        }
    }
    
    func payFlow(success:@escaping (_ request:URLRequest)->Void, failure:@escaping (NSError)->Void) {
        self.queryOrderInitNoComplete().then{() -> Promise<Void> in
            return self.queryMyOrderNoComplete()
        }.then{() -> Promise<Void> in
            return self.continuePayNoCompleteMyOrder()
        }.then{() -> Promise<Void> in
            return self.payOrderInit()
        }.then{()->Promise<URLRequest> in
            return self.paycheckNew()
        }.then{request in
            success(request)
        }.catch {error in
            failure(error as NSError)
        }
    }
// MARK: - Chainable Request
    func queryOrderInit()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/init"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/index/initMy12306"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
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
            Service.Manager.request(url, method:.post, parameters: params.ToPostParams(), headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let jsonData = JSON(data)["data"]
                    let orderDBList = jsonData["OrderDTODataList"]
                    guard orderDBList.count > 0 else {
                        let error = ServiceError.errorWithCode(.zeroOrderFailed)
                        reject(error)
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
    
    func queryOrderInitNoComplete()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/index/initMy12306"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseString(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func queryMyOrderNoComplete()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrderNoComplete"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let orderDBList = JSON(data)["data"]["orderDBList"]
                    MainModel.noCompleteOrderList = [OrderDTO]()
                    if orderDBList.count > 0{
                        for i in 0..<orderDBList.count {
                            MainModel.orderId = orderDBList[i]["sequence_no"].string
                            let ticketNum = orderDBList[i]["tickets"].count
                            for y in 0..<ticketNum {
                                let ticketOrder = OrderDTO(json: orderDBList[i], ticketIdx: y)
                                MainModel.noCompleteOrderList.append(ticketOrder)
                            }
                        }
                    }
                    fulfill()
            }})
        }
    }
    
    func continuePayNoCompleteMyOrder()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/continuePayNoCompleteMyOrder"
            let params = ["sequence_no":"\(MainModel.orderId!)",
                          "pay_flag":"pay",
                          "_json_att":""]
            print(params)
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                print(response)
                fulfill()
            })
        }
    }
    
    func payOrderInit()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/payOrder/init"
            let params = ["_json_att":""]
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseString(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func paycheckNew()->Promise<URLRequest>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/payOrder/paycheckNew"
            let params = PaycheckNewParam().ToPostParams()
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/initNoComplete"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    let json = JSON(data)["data"]
                    print(json)
                    if let flag =  json["flag"].bool {
                        if flag {
                            //make the request
                            let urlStr = "https://epay.12306.cn/pay/payGateway"
                            let headers = ["refer": "https://kyfw.12306.cn/otn/payOrder/init"]
                            let params = ["json_att":"",
                                          "interfaceName":"PAY_SERVLET",
                                          "interfaceVersion":"PAY_SERVLET",
                                          "tranData":json["payForm"]["tranData"].string!,
                                          "merSignMsg":json["payForm"]["merSignMsg"].string!,
                                          "appId":"0001",
                                          "transType":"01"
                                          ]
                            
                            let request = Alamofire.request(urlStr, method: .post, parameters:params, headers: headers).request
                            
                            fulfill(request!)
                        }
                    }
                }})
        }
    }
    
    
    
}
