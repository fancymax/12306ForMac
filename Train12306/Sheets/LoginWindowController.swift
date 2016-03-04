//
//  LoginWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/10.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa
import RealmSwift

class LoginWindowController: NSWindowController{

    @IBOutlet weak var passWord: NSSecureTextField!
    @IBOutlet weak var userName: AutoCompleteTextField!
    @IBOutlet weak var loginImage: RandCodeImageView!
    
    @IBOutlet weak var loadingTipBar: NSProgressIndicator!
    @IBOutlet weak var loadingTip: NSTextField!
    @IBOutlet weak var loadingTipView: GlassView!
    @IBOutlet weak var logStateLabel: FlashLabel!
    
    let service = Service()
    var users = [User]()
    
    @IBAction func freshImage(sender: NSButton)
    {
        loadImage()
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
            self.service.postMobileGetPassengerDTOs()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"handlerAfterSuccess", userInfo: nil, repeats: false)
        }
        
        service.loginFlow(user: userName.stringValue, passWord: passWord.stringValue, randCodeStr: loginImage.randCodeStr!, success: successHandler, failure: failureHandler)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
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
        
        userName.tableViewDelegate = self
        
        let realm = try! Realm()
        let users = realm.objects(User)
        for var i = 0; i < users.count; i++ {
            self.users.append(users[i])
        }
        Swift.print("user count = \(users.count)")
        
        loadImage()
    }
    
    func handlerAfterFailure(){
        self.logStateLabel.hidden = true
        //重新加载图片
        self.loadImage()
    }
   
    func handlerAfterSuccess(){
        let lastUserDefault = UserDefaultManager()
        lastUserDefault.lastUserName = userName.stringValue
        lastUserDefault.lastUserPassword = passWord.stringValue
        
        let realm = try! Realm()
        try! realm.write {
            realm.create(User.self, value: ["userName": userName.stringValue, "userPassword": passWord.stringValue], update: true)
        }
        
        //关闭登录窗口
        self.dismissWithModalResponse(NSModalResponseOK)
        self.logStateLabel.hidden = true
    }
    
    func loadImage(){
        self.loginImage.clearRandCodes()
        self.startLoadingTip("正在加载...")
        let successHandler = {(image:NSImage) -> () in
            self.loginImage.image = image
            self.stopLoginTip()
        }
        let failureHandler = {
            self.stopLoginTip()
            self.logStateLabel.hidden = false
            self.logStateLabel.show("获取验证码失败", forDuration: 0.1, withFlash: false)
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"hideLogStateLabel", userInfo: nil, repeats: false)
        }
        service.preLoginFlow(success: successHandler,failure: failureHandler)
    }
    
    func hideLogStateLabel(){
        self.logStateLabel.hidden = true
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}

// MARK: - AutoCompleteTableViewDelegate
extension LoginWindowController: AutoCompleteTableViewDelegate{
    func textField(textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        var matches = [String]()
        for  user in self.users {
            if let _ = user.userName.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
            {
                matches.append(user.userName)
            }
        }
        return matches
    }
    
    func didSelectItem(selectedItem: String) {
        for  user in self.users where user.userName == selectedItem {
            self.passWord.stringValue = user.userPassword
        }
    }
}