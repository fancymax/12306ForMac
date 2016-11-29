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
    
// MARK: - Request Flow
    func preLoginFlow(success:@escaping (NSImage)->Void,failure:@escaping (NSError)->Void){
        loginInit().then{dynamicJs -> Promise<Void> in
            return self.requestDynamicJs(dynamicJs, referHeader: ["refer": "https://kyfw.12306.cn/otn/login/init"])
        }.then{() -> Promise<Void> in
            after(interval: 1)
        }.then{_ -> Promise<NSImage> in
            return self.getPassCodeNewForLogin()
        }.then{ image in
            success(image)
        }.catch { error in
            failure(error as NSError)
        }
    }
    
    func loginFlow(user:String,passWord:String,randCodeStr:String,success:@escaping ()->Void,failure:@escaping (NSError)->Void){
        self.checkRandCodeForLogin(randCodeStr).then{() -> Promise<Void> in
            return self.loginUserWith(user, passWord: passWord, randCodeStr: randCodeStr)
        }.then{ () -> Promise<Void> in
            return self.initMy12306()
        }.then{ () -> Promise<Void> in
            return self.getPassengerDTOs(isSubmit: false)
        }.then{_ in
            success()
        }.catch { error in
            failure(error as NSError)
        }
    }
    
// MARK: - Chainable Request
    func loginInit()->Promise<String>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/init"
            let headers = ["refer": "https://kyfw.12306.cn/otn/leftTicket/init"]
            Service.Manager.request(url, headers:headers).responseString(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let content):
                    var dynamicJs = ""
                    if let matches = Regex("src=\"/otn/dynamicJs/([^\"]+)\"").getMatches(content){
                        dynamicJs = matches[0][0]
                    }
                    else{
                        logger.error("fail to get dynamicJs:\(content)")
                    }
                    fulfill(dynamicJs)
                }})
        }
    }
    
    func loginOut()
    {
        let url = "https://kyfw.12306.cn/otn/login/loginOut"
        Service.Manager.request(url).responseString(completionHandler:{response in
        })
    }
    
    func getPassCodeNewForLogin()->Promise<NSImage>{
        return Promise{ fulfill, reject in
            let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))//0~1
            let url = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&" + random.description
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(url, headers:headers).responseData{ response in
                switch (response.result){
                    case .failure(let error):
                        reject(error)
                    case .success(let data):
                        if let image = NSImage(data: data){
                            fulfill(image)
                        }
                        else{
                            let error = ServiceError.errorWithCode(.getRandCodeFailed)
                            reject(error)
                        }
                }}
        }
    }
    
    func checkRandCodeForLogin(_ randCodeStr:String)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
            let params = ["randCode":randCodeStr,"rand":"sjrand"]
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let msg = JSON(data)["data"]["msg"].string , msg == "TRUE"{
                        fulfill()
                    }
                    else{
                        let error = ServiceError.errorWithCode(.checkRandCodeFailed)
                        reject(error)
                    }
            }})
        }
    }
    
    func loginUserWith(_ user:String, passWord:String, randCodeStr:String)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/login/loginAysnSuggest"
            let params = ["loginUserDTO.user_name":user,"userDTO.password":passWord,"randCode":randCodeStr]
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let loginCheck = JSON(data)["data"]["loginCheck"].string , loginCheck == "Y"{
                        MainModel.userName = user
                        fulfill()
                    }
                    else{
                        let error:NSError
                        if let errorStr = JSON(data)["messages"][0].string{
                            error = ServiceError.errorWithCode(.checkRandCodeFailed, failureReason: errorStr)
                        }
                        else{
                            error = ServiceError.errorWithCode(.checkRandCodeFailed)
                        }
                        reject(error)
                    }
            }})
        }
    }
    
    func initMy12306()->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/index/initMy12306"
            let headers = ["refer": "https://kyfw.12306.cn/otn/login/init"]
            Service.Manager.request(url, headers:headers).responseString(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let matches = Regex("(var user_name='[^']+')").getMatches(data){
                        //for javascript
                        let context = JSContext()!
                        context.evaluateScript(matches[0][0])
                        MainModel.realName = context.objectForKeyedSubscript("user_name").toString()
                    }
                    else{
                        logger.error("can't get user_name")
                    }
                    fulfill()
            }})
        }
    }
    
}
