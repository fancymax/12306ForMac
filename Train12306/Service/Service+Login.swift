//
//  PcHTTPService+Login.swift
//  Train12306
//
//  Created by fancymax on 15/11/7.
//  Copyright © 2015年 fancy. All rights reserved.
//

import JavaScriptCore
import Cocoa

extension Service {
    
    func loginOut()
    {
        let url = "https://kyfw.12306.cn/otn/login/loginOut"
        setReferLeftTicketInit()
        Service.shareManager.GET(url,parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                print(url)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            }
        )
    }
    
    //login/init
    func loginInit()
    {
        //<script src="/otn/dynamicJs/luzztpx" type="text/javascript" xml:space="preserve"></script>
        let url = "https://kyfw.12306.cn/otn/login/init"
        setReferLeftTicketInit()
        Service.shareManager.responseSerializer = AFHTTPResponseSerializer()
        Service.shareManager.GET(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                print(url)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            }
        )
    }
    
    func getPassCodeNewForLogin(successHandler handle:(loadImage:NSImage)->(),failHandler:()->()){
        let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))//0~1
        let url = "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&" + random.description
        
        setReferLoginInit()
        Service.shareManager.responseSerializer = AFImageResponseSerializer()
        Service.shareManager.GET(url,parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let image = responseObject as? NSImage
                {
                    print(url)
                    handle(loadImage: image)
                }
                else
                {
                    logger.error("image is nil")
                    failHandler()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
                failHandler()
            }
        )
    }
    
    func login(user:String,passWord:String,randCodeStr:String,successHandler:()->(),failHandler:()->()){
        let cancelOperations = {
            Service.shareManager.operationQueue.cancelAllOperations()
        }
        
        let checkRandOperation = checkRandCodeAnsyn(randCodeStr, successHandler: {},failHandler: cancelOperations)
        let loginUserOperation = loginUserAsyn(user, passWord: passWord, randCodeStr: randCodeStr, successHandler: {}, failHandler: cancelOperations)
        let userLoginOperation = userLogin()
        let initMy12306Operation = initMy12306(successHandler, failHandler: failHandler)
        
        loginUserOperation.addDependency(checkRandOperation)
        userLoginOperation.addDependency(loginUserOperation)
        initMy12306Operation.addDependency(userLoginOperation)
        
        Service.shareManager.operationQueue.addOperations([checkRandOperation,loginUserOperation,initMy12306Operation], waitUntilFinished: false)
    }
    
    func checkRandCodeAnsyn(randCodeStr:String,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn"
        let params = ["randCode":randCodeStr,"rand":"sjrand"]
        
        setReferLoginInit()
        Service.shareManager.responseSerializer = AFJSONResponseSerializer()
        return Service.shareManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                guard let msg = JSON(responseObject)["data"]["msg"].string where msg == "TRUE" else{
                    logger.error("randCodeStr:\(randCodeStr) json:\(JSON(responseObject))")
                    failHandler()
                    return
                }
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
        })!
    }
    
    func loginUserAsyn(user:String,passWord:String,randCodeStr:String,successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/login/loginAysnSuggest"
        let params = ["loginUserDTO.user_name":user,"userDTO.password":passWord,"randCode":randCodeStr]
        
        setReferLoginInit()
        Service.shareManager.responseSerializer = AFJSONResponseSerializer()
        return Service.shareManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                guard let loginCheck = JSON(responseObject)["data"]["loginCheck"].string where loginCheck == "Y" else{
                    logger.error("\(JSON(responseObject))")
                    failHandler()
                    return
                }
                MainModel.isGetUserInfo = true
                successHandler()
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
            })!
    }
    
    func userLogin()->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/login/userLogin"
        let params = ["_json_att":""]
        
        setReferLoginInit()
        Service.shareManager.responseSerializer = AFJSONResponseSerializer()
        return Service.shareManager.OperationForPOST(url,parameters: params,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                logger.error(error.localizedDescription)
            })!
    }
    
    func initMy12306(successHandler:()->(),failHandler:()->())->AFHTTPRequestOperation
    {
        let url = "https://kyfw.12306.cn/otn/index/initMy12306"
        
        setReferLoginInit()
        Service.shareManager.responseSerializer = AFHTTPResponseSerializer()
        return Service.shareManager.OperationForGET(url,parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let content = NSString(data: (responseObject as! NSData), encoding: NSUTF8StringEncoding) as? String
                {
                    if let matches = Regex("(var user_name='[^']+')").getMatches(content){
                        //for javascript
                        let context = JSContext()
                        context.evaluateScript(matches[0][0])
                        MainModel.user.realName = context.objectForKeyedSubscript("user_name").toString()
                        successHandler()
                    }
                    else{
                        logger.error("can't match user_name")
                        failHandler()
                    }
                }
                else
                {
                    logger.error("content nil")
                    failHandler()
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failHandler()
                logger.error(error.localizedDescription)
            }
        )!
    }
    
}