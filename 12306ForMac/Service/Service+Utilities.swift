//
//  Service+Utilities.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/19.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation


extension Service {
    func getWanIP(success:(wanIP:String)->()){
        let url = "http://ifconfig.me/ip"
        Service.Manager.request(.GET, url).responseString(completionHandler:{ response in
            switch (response.result){
            case .Failure(let error):
                print(error)
            case .Success(let content):
                print(content)
                success(wanIP: content)
            }})}
}