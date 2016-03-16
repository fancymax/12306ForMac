//
//  Train.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import RealmSwift

class Train:Object{
    dynamic var trainCode = ""
    
    override static func primaryKey() -> String? {
        return "trainCode"
    }
}