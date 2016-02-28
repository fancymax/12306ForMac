//
//  PcHTTPService+Login.swift
//  Train12306
//
//  Created by fancymax on 15/11/7.
//  Copyright © 2015年 fancy. All rights reserved.
//

import JavaScriptCore
import Cocoa
import Alamofire
import PromiseKit

extension Service {
    
//    func loginOut()
//    {
//        let url = "https://kyfw.12306.cn/otn/login/loginOut"
//        Service.Manager.request(.GET, url).responseString(completionHandler:{response in
//            print(response.result)
//        })
//    }
    
    func preLoginFlow(success success:(loadImage:NSImage)->(),failure:()->()){
        loginInit().then({dynamicJs -> Promise<Void> in
            return self.requestDynamicJs(dynamicJs, referHeader: ["refer": "https://kyfw.12306.cn/otn/login/init"])
         }).then({_ -> Promise<NSImage> in
            return self.getPassCodeNewForLogin()
        }).then({ image in
            success(loadImage: image)
        }).error({ _ in
            failure()
        })
        
    }
    
    func loginInit()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/init"
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(.GET, url, headers:headers).responseString(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let content):
                    var dynamicJs = ""
                    if let matches = Regex("src=\"/otn/dynamicJs/([^\"]+)\"").getMatches(content){
                        dynamicJs = matches[0][0]
                        logger.debug("dynamicJs = \(dynamicJs)")
                    }
                    else{
                        logger.error("fail to get dynamicJs:\(content)")
                    }
                    fulfill(dynamicJs)
                }})
        }
    }
    
    func getPassCodeNewForLogin()->Promise<NSImage>{
        return Promise{ fulfill, reject in
            let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))//0~1
            let url = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&" + random.description
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(.GET, url, headers:headers).responseData({response in
                    switch (response.result){
                    case .Failure(let error):
                        reject(error)
                    case .Success(let data):
                        if let image = NSImage(data: data){
                            fulfill(image)
                        }
                        else{
                            reject(NSError(domain: "getPassCodeNewForLogin", code: 0, userInfo: nil))
                        }
                }})
        }
    }
    
    func loginFlow(user user:String,passWord:String,randCodeStr:String,success:()->(),failure:()->()){
        checkRandCodeForLogin(randCodeStr).then({_ -> Promise<String> in
            return self.loginUserWith(user, passWord: passWord, randCodeStr: randCodeStr)
        }).then({ _ -> Promise<String> in
            return self.initMy12306()
        }).then({_ in
            success()
        }).error({ _ in
            failure()
        })
    }
    
    func checkRandCodeForLogin(randCodeStr:String)->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
            let params = ["randCode":randCodeStr,"rand":"sjrand"]
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if let msg = JSON(data)["data"]["msg"].string where msg == "TRUE"{
                        fulfill(url)
                    }
                    else{
                        logger.error("randCodeStr:\(randCodeStr) json:\(JSON(data))")
                        reject(NSError(domain: "checkRandCodeForLogin:", code: 0, userInfo: nil))
                    }
            }})
        }
    }
    
    func loginUserWith(user:String, passWord:String, randCodeStr:String)->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/loginAysnSuggest"
            let params = ["loginUserDTO.user_name":user,"userDTO.password":passWord,"randCode":randCodeStr]
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if let loginCheck = JSON(data)["data"]["loginCheck"].string where loginCheck == "Y"{
                        MainModel.isGetUserInfo = true
                        fulfill(url)
                    }
                    else{
                        logger.error("\(JSON(data))")
                        reject(NSError(domain: "loginUserWith:", code: 0, userInfo: nil))
                    }
            }})
        }
    }
    
    func initMy12306()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/index/initMy12306"
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(.GET, url, headers:headers).responseString(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    if let matches = Regex("(var user_name='[^']+')").getMatches(data){
                        //for javascript
                        let context = JSContext()
                        context.evaluateScript(matches[0][0])
                        MainModel.realName = context.objectForKeyedSubscript("user_name").toString()
                    }
                    else{
                        logger.error("can't get user_name")
                    }
                    fulfill(url)
            }})
        }
    }
    
}