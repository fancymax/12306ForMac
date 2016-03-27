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
    dynamic var name:String {
        get {
            return fromStationName + " -> " + toStationName
        }
    }
    
    dynamic var fromStationName = "深圳"
    dynamic var toStationName = "福州"
    dynamic var date = "2016-03-14"
    var trainCodeArr:List<Train>!
    var seatArr:List<Seat>?
    var passengerArr = List<Passenger>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}