//
//  Passenger.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import RealmSwift

class Passenger:Object{
    dynamic var id = ""
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}