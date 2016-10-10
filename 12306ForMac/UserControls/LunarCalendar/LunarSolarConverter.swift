//
//  LunarSolarConverter.swift
//  LunarSolarConverter
//
//  Created by isee15 on 15/1/17.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

import Foundation

class LunarSolarConverter {
    static fileprivate let lunarDayStrs = ["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十",
        "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十",
        "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十","卅一","卅二"]
    static fileprivate let lunarMonthStrs = ["春节","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
    
    static func Conventer2lunarStr(_ solar: Date) -> String{
        let cal = Calendar(identifier: Calendar.Identifier.chinese)
        let unitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue
        let components = (cal as NSCalendar).components(NSCalendar.Unit(rawValue: unitFlag), from: solar)
        if components.day != 1 {
            return lunarDayStrs[components.day! - 1]
        }
        else{
            return lunarMonthStrs[components.month! - 1]
        }
    }
}
