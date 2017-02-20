//
//  LunarSolarConverter.swift
//  LunarSolarConverter
//
//  Created by isee15 on 15/1/17.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

import Foundation

class LunarSolarConverter {
    static private let lunarDayStrs = ["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十",
        "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十",
        "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十","卅一","卅二"]
    static private let lunarMonthStrs = ["春节","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
    
    static private let solarFestival = [
    "d0101":"元旦节",
    "d0214":"情人节",
    "d0308":"妇女节",
    "d0312":"植树节",
    "d0401":"愚人节",
    "d0501":"劳动节",
    "d0504":"青年节",
    "d0601":"儿童节",
    "d0701":"建党节",
    "d0801":"建军节",
    "d0910":"教师节",
    "d1001":"国庆节",
    "d1031":"万圣节",
    "d1111":"光棍节",
    "d1224":"平安夜",
    "d1225":"圣诞节"
    ]
    static private let lunarFestival = [
    "d0101":"春节",
    "d0115":"元宵节",
    "d0505":"端午节",
    "d0707":"七夕节",
    "d0815":"中秋节",
    "d1223":"小年",
    "d0100":"除夕" //除夕暂不支持显示
    ]
    
    static private func formatDay(date:Date) -> String {
        return ""
    }
    
    static private func formatDay(month:Int,day:Int) -> String {
        return String(format: "d%02d%02d", month,day)
    }
    
    static func Conventer2lunarStr(_ solar: Date) -> String{
        let solarCal  = Calendar.current
        let solarUnitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue
        let solarComponents = (solarCal as NSCalendar).components(NSCalendar.Unit(rawValue: solarUnitFlag), from: solar)
        let solarFestivalKey = formatDay(month: solarComponents.month!, day: solarComponents.day!)
        for key in solarFestival.keys {
            if key == solarFestivalKey {
                return solarFestival[key]!
            }
        }
        
        let lunarCal = Calendar(identifier: Calendar.Identifier.chinese)
        let lunarUnitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue
        let lunarComponents = (lunarCal as NSCalendar).components(NSCalendar.Unit(rawValue: lunarUnitFlag), from: solar)
        let lunarFestivalKey = formatDay(month: lunarComponents.month!, day: lunarComponents.day!)
        for key in lunarFestival.keys {
            if key == lunarFestivalKey {
                return lunarFestival[key]!
            }
        }
        
        if lunarComponents.day != 1 {
            return lunarDayStrs[lunarComponents.day! - 1]
        }
        else{
            return lunarMonthStrs[lunarComponents.month! - 1]
        }
    }
    
}
