//
//  LoginWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/10.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController {

    @IBOutlet weak var passWord: NSSecureTextField!
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var loginImage: RandomCodeImageView!
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    @IBOutlet weak var loadingFailureView: NSView!
    @IBOutlet weak var loadingSuccessView: NSView!
    
    let loginService = HTTPService()
    var user = User()
    var timer:NSTimer?
    
    @IBAction func freshImage(sender: NSButton)
    {
        loadImage()
    }
    
    override var windowNibName: String{
        return "LoginWindowController"
    }
    
    override func windowDidLoad() {
        loadingView.hidden = true
        loadingFailureView.hidden = true
        loadingSuccessView.hidden = true
        spinner.startAnimation(nil)
        userName.stringValue = user.name!
        passWord.stringValue = user.passWord!
        
        loginService.loginInit()
        loadImage()
    }
    
    func startLoginTip()
    {
        loadingSpinner.startAnimation(nil)
        loadingView.hidden = false
    }
    
    func stopLoginTip(){
        loadingSpinner.stopAnimation(nil)
        loadingView.hidden = true
    }
    
    func handlerAfterFailure(){
        self.loadingFailureView.hidden = true
        //重新加载图片
        self.loadImage()
    }
    
    func handlerAfterSuccess(){
        self.loadingSuccessView.hidden = true
        //关闭登录窗口
        self.dismissWithModalResponse(NSModalResponseOK)
    }
    
    @IBAction func okayButtonClicked(button:NSButton){
        //显示正在登录
        startLoginTip()
        
        let failureHandler = {()->() in
            //关闭正在登录提示
            self.stopLoginTip()
            //显示登录失败 持续一秒
            self.loadingFailureView.hidden = false
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"handlerAfterFailure", userInfo: nil, repeats: false)
        }
        
        let successHandler = {()->() in
            //关闭正在登录提示
            self.stopLoginTip()
            //显示登录成功  持续一秒
            self.loadingSuccessView.hidden = false
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"handlerAfterSuccess", userInfo: nil, repeats: false)
        }
        //调用service
        println("\(loginImage.randCodeStr)")
        loginService.checkRandCodeAnsyn(userName.stringValue,passWord: passWord.stringValue,randCodeStr: loginImage.randCodeStr!,successHandler: successHandler,failureHandler: failureHandler)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func loadImage(){
        let handler = {(image:NSImage) -> () in
            self.loginImage.clearRandCodes()
            self.loginImage.image = image
            self.spinner.stopAnimation(nil)
        }
        loginService.loadLoginImage(successHandler: handler)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
    
}
