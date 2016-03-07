//
//  OrderQueueDTO.swift
//  Train12306
//
//  Created by fancymax on 16/3/3.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class OrderQueueResult{
    var count:String?
    var countT:String?
    var op_2:String?
    var op_1:String?
    var ticket:String?
    
    init(json:JSON)
    {
        count = json["count"].string
        countT = json["countT"].string
        op_1 = json["op_1"].string
        op_2 = json["op_2"].string
        ticket = json["ticket"].string
    }
    
    
}
