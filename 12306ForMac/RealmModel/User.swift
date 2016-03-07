//
//  Person.swift
//  Train12306
//
//  Created by fancymax on 16/2/19.
//  Copyright © 2016年 fancy. All rights reserved.
//

import RealmSwift

class User:Object{
    dynamic var userName = ""
    dynamic var userPassword = ""
    
    override static func primaryKey() -> String? {
        return "userName"
    }
}
