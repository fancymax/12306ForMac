//
//  Service+QueryOrder.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

extension Service{
    
    func GetHistoryOrder(successHandler:()->(),failHandler:()->()){
        let queryOrderInitOp = queryOrderInit()
        let queryMyOrderOp = queryMyOrder(successHandler,failHandler: failHandler)
        
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
                print(responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            }
        )!
    }
    
    func queryMyOrder(successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/queryOrder/queryMyOrder"
        let params = QueryOrderParam()
        
        setReferQueryOrderInit()
        Service.shareManager.responseSerializer = AFJSONResponseSerializer()
        return Service.shareManager.OperationForPOST(url,parameters: params.ToPostParams(),
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let jsonData = JSON(responseObject)["data"]
                guard jsonData["OrderDTODataList"].count > 0 else {
                    print("queryMyOrder:\(jsonData)")
                    failHandler()
                    return
                }
                MainModel.orderDTODataList = [OrderDTOData]()
                let num = jsonData["OrderDTODataList"].count
                var orderNum = 0
                if num <= 8 {
                    orderNum = num
                }
                else{
                    orderNum = 8
                }
                for i in 0...orderNum-1 {
                    MainModel.orderDTODataList!.append(OrderDTOData(jsonData:jsonData["OrderDTODataList"][i]))
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
