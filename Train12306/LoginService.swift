//
//  LoginService.swift
//  Train12306
//
//  Created by fancymax on 15/8/10.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

extension HTTPService {
    
    func loginInit()
    {
        let url = "https://kyfw.12306.cn/otn/login/init"
        shareHTTPManager.responseSerializer = AFHTTPResponseSerializer()
        shareHTTPManager.GET(
            url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if let content = NSString(data: (responseObject as! NSData), encoding: NSUTF8StringEncoding) as? String
                {
                    println(content)
                }
                else
                {
                    println("content nil")
                    
                }

            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
    }
    
    func checkRandCodeAnsyn(user:String,passWord:String,randCodeStr:String,successHandler:()->(),failureHandler:()->())
    {
        let checkRandURl = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
        var params = ["randCode":randCodeStr,"rand":"sjrand"]
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(checkRandURl,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let result = json["data"]["result"].string
                    {
                        println("result:" + result)
                    }
                    if let msg = json["data"]["msg"].string
                    {
                        println("msg:" + msg)
                        
                        if(msg == "TRUE")
                        {
                            self.loginAysnSuggest(user, passWord: passWord, randCodeStr: randCodeStr,successHandler: successHandler, failureHandler: failureHandler)
                        }else{
                            failureHandler()
                        }
                        
                    }
                }
                else
                {
                    println("content nil")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                failureHandler()
                println("Error: " + error.localizedDescription)
        })
    }
    
    
    func loginAysnSuggest(user:String,passWord:String,randCodeStr:String,successHandler:()->(),failureHandler:()->())
    {
        let url = "https://kyfw.12306.cn/otn/login/loginAysnSuggest"
        println(user)
        var params = ["loginUserDTO.user_name":user,"userDTO.password":passWord,"randCode":randCodeStr]
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    if let result = json["data"]["otherMsg"].string
                    {
                        println("otherMsg:" + result)
                    }
                    if let msg = json["data"]["loginCheck"].string
                    {
                        println("loginCheck:" + msg)
                        if(msg == "Y")
                        {
                            successHandler()
                        }
                        else{
                            failureHandler()
                        }
                    }
                    else{
                        failureHandler()
                    }
                    
                    println("loginAysnSuggest")
                }
                else
                {
                    println("content nil")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                failureHandler()
                println("Error: " + error.localizedDescription)
            })
    }
    
    func userLogin()
    {
        let url = "https://kyfw.12306.cn/otn/login/userLogin"
        var params = ["_json_att":""]
        shareHTTPManager.responseSerializer = AFHTTPResponseSerializer()
        shareHTTPManager.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if let content = NSString(data: (responseObject as! NSData), encoding: NSUTF8StringEncoding) as? String
                {
                    println(content)
                }
                else
                {
                    println("content nil")
                    
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    func loadLoginImage(successHandler handle:(loadImage:NSImage)->())
    {
        let loginImageUrl = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&0.22716084984131157"
        
        shareHTTPManager.responseSerializer = AFImageResponseSerializer()
        shareHTTPManager.GET(
            loginImageUrl,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                if let image = responseObject as? NSImage
                {
                    println("\(image.size.height)")
                    println("\(image.size.width)")
                    handle(loadImage: image)
                }
                else
                {
                    println("content = nil?")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
        
    }
    
}