//
//  Person.swift
//  Train12306
//
//  Created by fancymax on 16/2/19.
//  Copyright © 2016年 fancy. All rights reserved.
//

import RealmSwift

class Passenger:Object{
    dynamic var id = ""
    dynamic var name = ""
}

class User:Object{
    dynamic var userName = ""
    dynamic var userPassword = ""
    let selectedPassengers = List<Passenger>()
    
    override static func primaryKey() -> String? {
        return "userName"
    }
}
