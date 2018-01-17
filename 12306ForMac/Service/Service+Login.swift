//
//  PcHTTPService+Login.swift
//  Train12306
//
//  Created by fancymax on 15/11/7.
//  Copyright © 2015年 fancy. All rights reserved.
//

import JavaScriptCore
import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

extension Service {
    
// MARK: - Request Flow
    func preLoginFlow(success:@escaping (NSImage)->Void,failure:@escaping (NSError)->Void){
        let cookie1 = HTTPCookie(properties: [.name:"RAIL_DEVICEID",.domain:"kyfw.12306.cn",.value:"CyeQGv5X_Y9BsIIkxXGf8s_wPmVs2yH4idlQo3d4KxgeY10nAnXWcm72qwxLLd_xqQm-v8UaFAVL7elDx_KFZw1FN3MkwJcbQAGtPIFEWfWPsdsOr5_jgjV-HSn7t-2u2fZgGrTOSCpfoYMOF41I1qWmNkGkObIX",.path:"/"])
        let cookie2 = HTTPCookie(properties: [.name:"RAIL_EXPIRATION",.domain:"kyfw.12306.cn",.value:"1516426090658",.path:"/"])
        Service.Manager.session.configuration.httpCookieStorage?.setCookie(cookie1!)
        Service.Manager.session.configuration.httpCookieStorage?.setCookie(cookie2!)
    
        loginInit().then{(dynamicJs) -> Promise<Void> in
            return self.requestDynamicJs(dynamicJs, referHeader: ["refer": "https://kyfw.12306.cn/otn/login/init"])
        }.then{_ -> Promise<NSImage> in
            return self.getPassCodeNewForLogin()
        }.then{ image in
            success(image)
        }.catch { error in
            failure(error as NSError)
        }
    }
    
    func loginFlow(user:String,passWord:String,randCodeStr:String,success:@escaping ()->Void,failure:@escaping (NSError)->Void){
        after(interval: 2).then{
            self.checkRandCodeForLogin(randCodeStr)
        }.then{() -> Promise<Void> in
            return self.loginUserWith(user, passWord: passWord, randCodeStr: randCodeStr)
        }.then{ () -> Promise<(Bool,String)> in
            return self.checkUAM()
        }.then{ (hasLogin,tk) -> Promise<Bool> in
            return self.uampassport(tk: tk)
        }.then{ (_) -> Promise<Void> in
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
                    
                    self.getConfigFromInitContent(content)
                    
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
            let param = CaptchaImageParam().ToGetParams()
            let url = "\(passport_captcha)?\(param)"
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
    
    func checkUAM() ->Promise<(Bool,String)> {
        return Promise{ fulfill, reject in
            let url = passport_authuam
            //TODO
            //$.jc_getcookie("tk");
            
            let params = ["appid":passport_appId]
            
            var headers:[String:String] = [:]
            headers[referKey] = referValueForLoginInit
            
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let result_code = JSON(data)["result_code"].int  {
                        var hasLogin = false
                        var tk = ""
                        if result_code == 0 {
                            if let apptk = JSON(data)["apptk"].string {
                                tk = apptk
                            }
                            if let newapptk = JSON(data)["newapptk"].string {
                                tk = newapptk
                            }
                            
                            hasLogin = true
                        }
                        else {
                            hasLogin = false
                        }
                        fulfill((hasLogin,tk))
                    }
                    else{
                        let error = ServiceError.errorWithCode(.loginFailed, failureReason: "checkUAM")
                        reject(error)
                    }
                }})
        }
        
    }
    
    func uampassport(tk:String) ->Promise<Bool>  {
        return Promise{ fulfill, reject in
            let url = "https://kyfw.12306.cn/otn/" + passport_authclient
            //TODO
            //$.jc_getcookie("tk");
            
            let params = ["tk":tk]
            
            var headers:[String:String] = [:]
            headers[referKey] = referValueForLoginInit
            
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let result_code = JSON(data)["result_code"].int  {
                        var hasLogin = false
                        if result_code == 0 {
                            hasLogin = true
                            if let userName = JSON(data)["username"].string {
                                MainModel.userName = userName
                            }
                        }
                        else {
                            hasLogin = false
                        }
                        fulfill(hasLogin)
                    }
                    else{
                        let error = ServiceError.errorWithCode(.loginFailed, failureReason: "uampassport")
                        reject(error)
                    }
                }})
        }
    }
    
    func checkRandCodeForLogin(_ randCodeStr:String)->Promise<Void>{
        return Promise{ fulfill, reject in
            let url = passport_captcha_check
            let params = ["answer":randCodeStr,"login_site":"E","rand":"sjrand"]
            let headers = ["Referer": "https://kyfw.12306.cn/otn/login/init",
                           "X-Requested-With":"XMLHttpRequest"]
            Service.Manager.request(url, method:.post, parameters: params, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let msg = JSON(data)["result_code"].string , msg == "4"{
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
            let url = passport_login
            
            let params = ["username":user,"password":passWord,"appid":passport_appId]
            let headers = ["Referer": "https://kyfw.12306.cn/otn/login/init",
                           "Origin":"https://kyfw.12306.cn",
                           "X-Requested-With":"XMLHttpRequest"]
            Service.Manager.request(url, method:.post, parameters: params,encoding: URLEncoding.default, headers:headers).responseJSON(completionHandler:{response in
                switch (response.result){
                case .failure(let error):
                    reject(error)
                case .success(let data):
                    if let result_code = JSON(data)["result_code"].int ,result_code == 0{
                        fulfill()
                    }
                    else{
                        let error:NSError
                        if let errorStr = JSON(data)["result_message"].string{
                            error = ServiceError.errorWithCode(.loginUserFailed, failureReason: errorStr)
                        }
                        else{
                            error = ServiceError.errorWithCode(.loginUserFailed)
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
