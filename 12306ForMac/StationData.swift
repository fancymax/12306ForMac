//
//  StationDataService.swift
//  Train12306
//
//  Created by fancymax on 15/8/4.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

struct Station {
    //首字母拼音 比如 bj
    var FirstLetter:String
    //车站名
    var Name:String
    //电报码
    var Code:String
    //全拼
    var Spell:String
}

// "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js"
class StationNameJs{
    fileprivate static let sharedManager = StationNameJs()
    class var sharedInstance: StationNameJs {
        return sharedManager
    }
    
    var allStation:[Station]
    
    var allStationMap:[String:Station]
    
    fileprivate init()
    {
        self.allStation = [Station]()
        self.allStationMap = [String:Station]()
        
        //1.8983
        let path = Bundle.main.path(forResource: "station_name", ofType: "js")
        let stationInfo = try! NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue) as String
        
        if let matches = Regex("@[a-z]+\\|([^\\|]+)\\|([a-z]+)\\|([a-z]+)\\|([a-z]+)\\|").getMatches(stationInfo)
        {
            for match in matches
            {
                let oneStation = Station(FirstLetter:match[3],Name:match[0],Code:match[1],Spell:match[2])
                self.allStation.append(oneStation)
                self.allStationMap[oneStation.Name] = oneStation
            }
        }

    }
}
