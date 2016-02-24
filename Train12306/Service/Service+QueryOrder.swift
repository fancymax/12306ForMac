//
//  Service+QueryOrder.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import AFNetworking

extension Service{
    
    func GetHistoryOrder(successHandler:()->(),_ failHandler:()->()){
        let queryOrderInitOp = queryOrderInit()
        let queryMyOrderOp = queryMyOrder(successHandler,failHandler)
        
        queryMyOrderOp.addDependency(queryOrderInitOp)
        Service.shareManager.operationQueue.addOperations([queryOrderInitOp,queryMyOrderOp], waitUntilFinished: false)
    }
    
    func queryOrderInit()-> AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/queryOrder/init"
        let params = ["_json_att":""]
        
        setReferInitMy12306()
        Service.shareManager.responseSerializer = AFHTTPResponseSerializer()
        return Service.shareManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
//                print(responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            }
        )!
    }
    
    func queryMyOrder(successHandler:()->(),_ failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrder"
        let params = QueryOrderParam().ToPostParams()
        
        setReferQueryOrderInit()
        Service.shareManager.responseSerializer = AFJSONResponseSerializer()
        return Service.shareManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let jsonData = JSON(responseObject)["data"]
                guard jsonData["OrderDTODataList"].count > 0 else {
                    print("queryMyOrder:\(jsonData)")
                    failHandler()
                    return
                }
                MainModel.historyOrderList.removeAll()
                let num = jsonData["OrderDTODataList"].count
                for i in 0...num-1 {
                    MainModel.historyOrderList.append(OrderDTOData(jsonData:jsonData["OrderDTODataList"][i]))
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
