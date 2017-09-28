//
//  captchaImageParam.swift
//  12306ForMac
//
//  Created by fancymax on 2017/9/28.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Foundation

struct CaptchaImageParam {
    var login_site:String = "E"
    var module:String = "login"
    var rand:String = "sjrand"
    
    func ToGetParams()->String{
        let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))//0~1
        return "login_site=\(login_site)&module=\(module)&rand=\(rand)&" + random.description
    }
}
