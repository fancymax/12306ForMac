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
        
        window!.styleMask |= NSUnifiedTitleAndToolbarWindowMask
        window!.styleMask = window!.styleMask & (~NSFullSizeContentViewWindowMask)
        window!.styleMask |= NSTitledWindowMask
        window!.titleVisibility = .Hidden;
        
        moduleSegment.segmentCount = 2
        moduleSegment.setLabel(TrainBook, forSegment: 0)
        moduleSegment.setLabel(TrainOrder, forSegment: 1)
        moduleSegment.selectedSegment = 0
        moduleSegment.segmentStyle = NSSegmentStyle.TexturedSquare
        moduleSegment.target = self
        moduleSegment.action = #selector(MainWindowController.segmentTab(_:))
        
        selectModule(TrainBook)
        
        self.window?.recalculateKeyViewLoop()
        
        //login notification
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MainWindowController.receiveDidSendLoginMessageNotification(_:)), name: DidSendLoginMessageNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MainWindowController.receiveAutoLoginMessageNotification(_:)), name: DidSendAutoLoginMessageNotification, object: nil)
    }
    
    func segmentTab(sender: NSSegmentedControl){
        selectModule(sender.labelForSegment(sender.selectedSegment)!)
    }
    
    func selectModule(moduleName:String){
        if(moduleName == TrainOrder){
            self.window?.contentView = orderQueryViewController.view
        }
        else if(moduleName == TrainBook){
            self.window?.contentView = ticketQueryViewController.view
        }
    }
    
    func receiveDidSendLoginMessageNotification(note: NSNotification){
        loginOut()
        login(isAutoLogin: false)
    }
    
    func receiveAutoLoginMessageNotification(note: NSNotification){
        loginOut()
        login(isAutoLogin: true)
    }
    
    @IBAction func UserLogin(sender: NSButton){
        if !MainModel.isGetUserInfo{
            self.login(isAutoLogin: false)
        }
        else{
            var position:NSPoint = sender.convertPointToBacking(sender.frame.origin)
            position.y += sender.bounds.size.height + 10
            position.x -= 4
            self.LoginMenu.minimumWidth = sender.bounds.size.width
            self.LoginMenu.popUpMenuPositioningItem(nil, atLocation: position, inView: sender)
        }
    }
    
    @IBAction func loginOut(sender: NSMenuItem) {
        loginOut()
    }
    
    @IBAction func openPreferences(sender:AnyObject){
        self.preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func showHelp(sender:AnyObject) {
        sendEmailWithMail()
    }
    
    func loginOut(){
        MainModel.isGetUserInfo = false
        MainModel.isGetPassengersInfo = false
        MainModel.passengers = [PassengerDTO]()
        NSNotificationCenter.defaultCenter().postNotificationName(DidSendLogoutMessageNotification, object:nil)
        loginButton.title = "登录 ▾"
        let service = Service()
        service.loginOut()
    }
    
    
    func login(isAutoLogin isAutoLogin :Bool){
        loginWindowController = LoginWindowController()
        loginWindowController.isAutoLogin = isAutoLogin
        
        if let window = self.window {
            window.beginSheet(loginWindowController.window!) {
                if $0 == NSModalResponseOK{
                    self.loginButton.title = MainModel.realName
                }
            }
        }
    }
    
    func sendEmailWithMail() {
        let receiver = "lindahai_max@126.com"
        let subject = "12306ForMac Feedback"
        
        let mailToAddress = "mailto:\(receiver)?Subject=\(subject)"
        let mailUrl = NSURL(string: mailToAddress.stringByReplacingOccurrencesOfString(" ", withString: "%20"))
        NSWorkspace.sharedWorkspace().openURL(mailUrl!)
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
}

