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
    @IBOutlet weak var damaBtn: URLButton!
    @IBOutlet weak var moduleSegment: NSSegmentedControl!
    @IBOutlet var LoginMenu: NSMenu!
    @IBOutlet weak var pageBox: NSBox!
    
    var orderQueryViewController = OrderViewController()
    var ticketQueryViewController = TicketQueryViewController()
    
    var loginWindowController:LoginWindowController!
    
    lazy var preferencesWindowController:MASPreferencesWindowController = {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainWindowController.recvLoginNotification(_:)), name: NSNotification.Name.App.DidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainWindowController.recvAutoLoginNotification(_:)), name: NSNotification.Name.App.DidAutoLogin, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainWindowController.recvDamaSuccessNotification(_:)), name: NSNotification.Name.App.DidDamaGetBalance, object: nil)
        
        //申请日历权限
        CalendarManager.sharedInstance.updateAuthorizationStatus()
        
        self.setupDamaBtn()
    }
    
    @IBAction func goRightTab(_ sender:AnyObject?) {
        selectModule(TrainOrder)
        moduleSegment.setSelected(true, forSegment: 1)
    }
    
    @IBAction func goLeftTab(_ sender:AnyObject?) {
        selectModule(TrainBook)
        moduleSegment.setSelected(true, forSegment: 0)
    }
    
    func segmentTab(_ sender: NSSegmentedControl){
        selectModule(sender.label(forSegment: sender.selectedSegment)!)
    }
    
    func selectModule(_ moduleName:String){
        if(moduleName == TrainOrder){
            self.pageBox.contentView = orderQueryViewController.view
        }
        else if(moduleName == TrainBook){
            self.pageBox.contentView = ticketQueryViewController.view
        }
        self.window?.makeFirstResponder(self.pageBox.contentView)
    }
    
    func recvLoginNotification(_ note: Notification){
        loginOut()
        login(isAutoLogin: false)
    }
    
    func recvAutoLoginNotification(_ note: Notification){
        loginOut()
        login(isAutoLogin: true)
    }
    
    func recvDamaSuccessNotification(_ note: Notification){
        if let isSuccess = note.object as? Bool {
            if isSuccess {
                damaBtn.title = "打码兔🔵"
            }
            else {
                damaBtn.title = "打码兔🔴"
            }
        }
        else {
            damaBtn.title = "打码兔🔵"
            
        }
    }
    
    func setupDamaBtn() {
        if AdvancedPreferenceManager.sharedInstance.isUseDama {
            damaBtn.title = "打码兔🔵"
        }
        else {
            damaBtn.title = "打码兔🔴"
        }
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
    
    @IBAction func openDamaSetting(_ sender: NSButton) {
        self.preferencesWindowController.select(withIdentifier: "AdvancedPreferences")
        self.preferencesWindowController.showWindow(nil)
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
                    MainModel.isGetUserInfo = true
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

