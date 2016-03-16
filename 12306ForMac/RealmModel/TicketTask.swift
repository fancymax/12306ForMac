//
//  TicketTask.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import RealmSwift

class TicketTask:Object{
    dynamic var id = 0
    dynamic var name = "抢票任务1"
    dynamic var fromStationName = ""
    dynamic var toStationName = ""
    dynamic var date = NSDate()
    var trainCodeArr:List<Train>!
    var seatArr:List<Seat>?
    var passengerArr:List<Passenger>!
    
}