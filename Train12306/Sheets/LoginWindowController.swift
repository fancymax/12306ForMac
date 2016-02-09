//
//  LoginWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/10.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController{

    @IBOutlet weak var passWord: NSSecureTextField!
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var loginImage: RandCodeImageView!
    
    @IBOutlet weak var loadingTipBar: NSProgressIndicator!
    @IBOutlet weak var loadingTip: NSTextField!
    @IBOutlet weak var loadingTipView: GlassView!
    @IBOutlet weak var logStateLabel: FlashLabel!
    
    let service = Service()
    
    @IBAction func freshImage(sender: NSButton)
    {
        loadImage()
    }
    
    override var windowNibName: String{
        return "LoginWindowController"
    }
    
    func startLoadingTip(tip:String)
    {
        loadingTipBar.startAnimation(nil)
        loadingTip.stringValue = tip
        loadingTipView.hidden = false
    }
    
    func stopLoginTip(){
        loadingTipBar.stopAnimation(nil)
        loadingTipView.hidden = true
    }
    
    override func windowDidLoad() {
        logStateLabel.hidden = true
        let lastUserDefault = UserDefaultManager()
        if let lastName = lastUserDefault.lastUserName,let lastPassword = lastUserDefault.lastUserPassword{
            userName.stringValue = lastName
            passWord.stringValue = lastPassword
        }
        
        loadImage()
    }
    
    func handlerAfterFailure(){
        self.logStateLabel.hidden = true
        //重新加载图片
        self.loadImage()
    }
   
    func handlerAfterSuccess(){
        self.logStateLabel.hidden = true
        let lastUserDefault = UserDefaultManager()
        lastUserDefault.lastUserName = userName.stringValue
        lastUserDefault.lastUserPassword = passWord.stringValue
        
        //关闭登录窗口
        self.dismissWithModalResponse(NSModalResponseOK)
    }
    
    @IBAction func okayButtonClicked(button:NSButton){
        self.logStateLabel.hidden = false
        if userName.stringValue == "" || passWord.stringValue == "" {
            self.logStateLabel.show("请先输入用户名和密码", forDuration: 0.1, withFlash: false)
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"hideLogStateLabel", userInfo: nil, repeats: false)
            return
        }
        if loginImage.randCodeStr == nil {
            self.logStateLabel.show("请先选择验证码", forDuration: 0.1, withFlash: false)
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"hideLogStateLabel", userInfo: nil, repeats: false)
            return
        }
        //显示正在登录
        button.enabled = false
        
        self.startLoadingTip("正在登录...")
        
        let failureHandler = {
            //关闭正在登录提示
            button.enabled = true
            self.stopLoginTip()
            //显示登录失败 持续一秒
            self.logStateLabel.show("登录失败", forDuration: 0.1, withFlash: false)
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector:"handlerAfterFailure", userInfo: nil, repeats: false)
        }
        
        let successHandler = {
            //关闭正在登录提示
            self.stopLoginTip()
            //显示登录成功  持续一秒
            self.logStateLabel.show("登录成功", forDuration: 0.1, withFlash: false)
            button.enabled = true
            self.service.postMobileGetPassengerDTOs({})
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"handlerAfterSuccess", userInfo: nil, repeats: false)
        }
        //调用service
        service.login(userName.stringValue, passWord: passWord.stringValue, randCodeStr: loginImage.randCodeStr!, successHandler: successHandler, failHandler: failureHandler)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func loadImage(){
        self.loginImage.clearRandCodes()
        self.startLoadingTip("正在加载...")
        let successHandler = {(image:NSImage) -> () in
            self.loginImage.image = image
            self.stopLoginTip()
        }
        let failHandler = {
            self.stopLoginTip()
            self.logStateLabel.hidden = false
            self.logStateLabel.show("获取验证码失败", forDuration: 0.1, withFlash: false)
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"hideLogStateLabel", userInfo: nil, repeats: false)
        }
        service.beforeLogin(successHandler,failHandler: failHandler)
    }
    
    func hideLogStateLabel(){
        self.logStateLabel.hidden = true
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
    
}
