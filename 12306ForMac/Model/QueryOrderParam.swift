//
//  QueryOrderParam.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct QueryOrderParam{
    var queryType = "1"
    var queryStartDate = "2016-06-01"
    var queryEndDate = "2020-02-15"
    var come_from_flag = "my_order"
    var pageSize = 8
    var pageIndex = 0
    var query_where = "G"
    var sequeue_train_name = ""
    
    func ToPostParams()->[String:String]{
        return ["queryType":queryType,
                "queryStartDate":queryStartDate,
                "queryEndDate":queryEndDate,
                "come_from_flag":come_from_flag,
                "pageSize":String(pageSize),
                "pageIndex":String(pageIndex),
                "query_where":query_where,
                "sequeue_train_name":sequeue_train_name,
        ]
    }
}
