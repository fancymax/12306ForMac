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
    @IBOutlet var LoginMenu: NSMenu!
    @IBOutlet var IPLabel: NSTextField!
    
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
        
        let aWindow = self.window as! INAppStoreWindow
        aWindow.titleBarHeight = 38.0
    	aWindow.centerTrafficLightButtons = true;
        
        aWindow.titleBarDrawingBlock = {[unowned self] drawsAsMainWindow, drawingRect, edge, clippingPath  in
            NotificationCenter.default.post(name: NSNotification.Name.NSWindowDidMove, object:self.window)
        }
        
        
        let titleView = aWindow.titleBarView
        let buttonPoint = NSMakePoint(85, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
        titleView?.addSubview(self.loginButton)
        
        let segmentSize = NSMakeSize(120, 25)
        let segmentFrame = NSMakeRect(
            NSMidX((titleView?.bounds)!) - (segmentSize.width / 2.0),
            NSMidY((titleView?.bounds)!) - (segmentSize.height / 2.0),
            segmentSize.width, segmentSize.height)
        let segment = NSSegmentedControl(frame: segmentFrame)
        segment.segmentCount = 2
        segment.setLabel(TrainBook, forSegment: 0)
        segment.setLabel(TrainOrder, forSegment: 1)
        segment.selectedSegment = 0
        segment.segmentStyle = NSSegmentStyle.texturedSquare
        segment.target = self
        segment.action = #selector(MainWindowController.segmentTab(_:))
        
        titleView?.addSubview(segment)
        
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        let segmentConstraint1 = NSLayoutConstraint(item: segment, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        let segmentConstraint2 = NSLayoutConstraint(item: segment, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([segmentConstraint1,segmentConstraint2])
        
        selectModule(TrainBook)
        
        self.window?.recalculateKeyViewLoop()
        
        //login notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receiveDidSendLoginMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendLoginMessageNotification), object: nil)
        notificationCenter.addObserver(self, selector: #selector(receiveAutoLoginMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendAutoLoginMessageNotification), object: nil)
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
        } else {
            var position:NSPoint = sender.bounds.origin
            position.y += sender.bounds.size.height + 5
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
    
    @IBAction func showHelp(_ sender:AnyObject) {
        sendEmailWithMail()
    }
    
    func loginOut(){
        MainModel.isGetUserInfo = false
        MainModel.isGetPassengersInfo = false
        MainModel.passengers = [PassengerDTO]()
        NotificationCenter.default.post(name: Notification.Name(rawValue: DidSendLogoutMessageNotification), object:nil)
        loginButton.title = "登录 ▾"
        let service = Service()
        service.loginOut()
    }
    
    
    func login(isAutoLogin :Bool){
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
        let mailUrl = URL(string: mailToAddress.replacingOccurrences(of: " ", with: "%20"))
        NSWorkspace.shared().open(mailUrl!)
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
}

extension MainWindowController: NSWindowDelegate {
    func windowWillEnterFullScreen(_ notification: Notification) {
        let buttonPoint = NSMakePoint(20, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        let buttonPoint = NSMakePoint(85, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
    }
}

