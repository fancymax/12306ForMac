//
//  Refresh12306CDN.swift
//  12306ForMac
//
//  Created by zc on 2016/12/21.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class Refresh12306CDN {
    // http://tool.chinaz.com/dns/?type=1&host=kyfw.12306.cn&ip=
    // 暂时先写死 kyfw.12306.cn 的 cdn 地址，若是 cdn 地址变更频繁则需要动态获取
    private let cdnList = ["61.147.211.20", "114.64.222.62",
                           "119.90.19.39", "175.25.168.40",
                           "119.90.19.40", "101.227.102.198",
                           "116.224.87.45", "42.81.5.76",
                           "60.213.21.211", "123.128.14.223",
                           "60.211.208.49", "58.20.179.92",
                           "58.20.164.51", "60.5.255.230",
                           "211.144.7.85", "111.11.197.55",
                           "58.51.241.34", "116.211.79.31",
                           "58.51.150.55", "223.111.18.217",
                           "112.25.35.79", "218.197.116.213",
                           "218.197.116.214", "60.213.21.211",
                           "116.57.77.35", "116.57.77.39",
                           "222.23.55.208", "220.162.97.209",
                           "113.16.210.132", "59.56.30.206",
                           "113.107.57.43", "113.107.57.43"]
    private var currentIndex = 0
    static let sharedInstance: Refresh12306CDN = Refresh12306CDN()
    
    private init() {}
    
    func refresh() -> String {
        if currentIndex == cdnList.count {
            currentIndex = 0
        }
        let ip = cdnList[currentIndex]
        if (ModifyHosts.sharedInstance().udpateHostsFor12306(ip)) {
            currentIndex += 1
        }
        return ip
    }
}
