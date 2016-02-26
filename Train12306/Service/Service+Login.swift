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
//        Service.Manager1.request(.GET, url).responseString(completionHandler:{response in
//            print(response.result)
//        })
//    }
    
    func preLoginFlow(success success:(loadImage:NSImage)->(),failure:()->()){
        loginInit().then({_ -> Promise<NSImage> in
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
            Service.Manager1.request(.GET, url, headers:headers).responseString(completionHandler:{response in
                
            })
            fulfill("Always Succeed")
        }
    }
    
    func getPassCodeNewForLogin()->Promise<NSImage>{
        return Promise{ fulfill, reject in
            let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))//0~1
            let url = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&" + random.description
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager1.request(.GET, url, headers:headers).responseData({response in
                    switch (response.result){
                    case .Failure(let error):
                        reject(error)
                    case .Success(let data):
                        let image = NSImage(data: data)!
                        fulfill(image)
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
            Service.Manager1.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    guard let msg = JSON(data)["data"]["msg"].string where msg == "TRUE" else{
                        logger.error("randCodeStr:\(randCodeStr) json:\(JSON(data))")
                        return
                }
                fulfill(url)
                
            }})
        }
    }
    
    func loginUserWith(user:String, passWord:String, randCodeStr:String)->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/loginAysnSuggest"
            let params = ["loginUserDTO.user_name":user,"userDTO.password":passWord,"randCode":randCodeStr]
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager1.request(.POST, url, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .Failure(let error):
                    reject(error)
                case .Success(let data):
                    guard let loginCheck = JSON(data)["data"]["loginCheck"].string where loginCheck == "Y" else{
                        logger.error("\(JSON(data))")
                        return
                    }
                    MainModel.isGetUserInfo = true
                    fulfill(url)
            }})
        }
    }
    
    func initMy12306()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/index/initMy12306"
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager1.request(.GET, url, headers:headers).responseString(completionHandler:{response in
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
                        logger.error("can't match user_name")
                    }
                    fulfill(url)
            }})
        }
    }
    
}