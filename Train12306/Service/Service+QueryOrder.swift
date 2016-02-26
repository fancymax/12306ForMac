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
        self.queryOrderInit().then({()->Promise<String> in
            return self.queryMyOrder()
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
            Service.Manager1.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                fulfill()
            })
        }
    }
    
    func queryMyOrder()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrder"
            let params = QueryOrderParam().ToPostParams()
            let headers = ["refer": "https://kyfw.12306.cn/otn/queryOrder/init"]
            Service.Manager1.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    let jsonData = JSON(data)["data"]
                    guard jsonData["OrderDTODataList"].count > 0 else {
                        print("queryMyOrder:\(jsonData)")
                        return
                    }
                    MainModel.historyOrderList.removeAll()
                    let num = jsonData["OrderDTODataList"].count
                    for i in 0...num-1 {
                        MainModel.historyOrderList.append(OrderDTOData(jsonData:jsonData["OrderDTODataList"][i]))
                    }
                    fulfill(url)
            }})
        }
    }
    
}
