//
//  MainWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController{
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var moduleSegment: NSSegmentedControl!
    @IBOutlet var LoginMenu: NSMenu!
    
    var orderQueryViewController = OrderViewController()
    var ticketQueryViewController = TicketQueryViewController()
    
    var loginWindowController:LoginWindowController!
    
    lazy var preferencesWindowController:NSWindowController = {
        let generalViewController = GeneralPreferenceViewController()
        let advanceViewController = AdvancedPreferenceViewController()
        let controllers = [generalViewController,advanceViewController]
        
        return MASPreferencesWindowController(viewControllers:controllers,title: nil)
    }()
    
    let TrainBook = "车票预订"
    let TrainOrder = "订单查询"
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        window!.titleVisibility = .hidden;
        
        moduleSegment.selectedSegment = 0
        moduleSegment.target = self
        moduleSegment.action = #selector(MainWindowController.segmentTab(_:))
        
        selectModule(TrainBook)
        
        self.window?.recalculateKeyViewLoop()
        
        //login notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MainWindowController.receiveDidSendLoginMessageNotification(_:)), name: NSNotification.Name.App.DidLogin, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MainWindowController.receiveAutoLoginMessageNotification(_:)), name: NSNotification.Name.App.DidAutoLogin, object: nil)
    }
    
    func segmentTab(_ sender: NSSegmentedControl){
        selectModule(sender.label(forSegment: sender.selectedSegment)!)
    }
    
    func selectModule(_ moduleName:String){
        if(moduleName == TrainOrder){
            self.window?.contentView = orderQueryViewController.view
        }
        else if(moduleName == TrainBook){
            self.window?.contentView = ticketQueryViewController.view
        }
    }
    
    func receiveDidSendLoginMessageNotification(_ note: Notification){
        loginOut()
        login(isAutoLogin: false)
    }
    
    func receiveAutoLoginMessageNotification(_ note: Notification){
        loginOut()
        login(isAutoLogin: true)
    }
    
    @IBAction func UserLogin(_ sender: NSButton){
        if !MainModel.isGetUserInfo{
            self.login(isAutoLogin: false)
        }
        else{
            var position:NSPoint = sender.convertToBacking(sender.frame.origin)
            position.y += sender.bounds.size.height + 10
            position.x -= 4
            self.LoginMenu.minimumWidth = sender.bounds.size.width
            self.LoginMenu.popUp(positioning: nil, at: position, in: sender)
        }
    }
    
    @IBAction func loginOut(_ sender: NSMenuItem) {
        loginOut()
    }
    
    @IBAction func openPreferences(_ sender:AnyObject){
        self.preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func EmailAuthor(_ sender:AnyObject) {
        sendEmailWithMail()
    }
    
    @IBAction func reportIssue(_ sender:AnyObject) {
        NSWorkspace.shared().open(URL(string: "https://github.com/fancymax/12306ForMac/issues")!)
    }
    
    @IBAction func rateInAppstore(_ sender:AnyObject){
        NSWorkspace.shared().open(URL(string: "macappstore://itunes.apple.com/us/app/ding-piao-zhu-shou/id1163682213?l=zh&ls=1&mt=12")!)
    }
    
    func loginOut(){
        MainModel.isGetUserInfo = false
        MainModel.isGetPassengersInfo = false
        MainModel.passengers = [PassengerDTO]()
        NotificationCenter.default.post(name: Notification.Name.App.DidLogout, object:nil)
        loginButton.title = "登录 ▾"
        Service.sharedInstance.loginOut()
    }
    
    
    func login(isAutoLogin :Bool){
        loginWindowController = LoginWindowController()
        loginWindowController.isAutoLogin = isAutoLogin
        logger.info("-> login isAuto=\(isAutoLogin)")
        
        if let window = self.window {
            window.beginSheet(loginWindowController.window!) {
                if $0 == NSModalResponseOK{
                    self.loginButton.title = MainModel.realName
                    NotificationCenter.default.post(name: Notification.Name.App.DidAddDefaultPassenger, object:nil)
                    logger.info("<- login")
                }
            }
        }
    }
    
    func sendEmailWithMail() {
        let receiver = "lindahai_max@126.com"
        let subject = "12306ForMac Feedback"
        
        let mailToAddress = "mailto:\(receiver)?Subject=\(subject)"
        let mailUrl = URL(string: mailToAddress.replacingOccurrences(of: " ", with: "%20"))
        NSWorkspace.shared().open(mailUrl!)
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
}

