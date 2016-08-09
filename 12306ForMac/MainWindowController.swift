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
    
    var orderQueryViewController:OrderViewController?
    var ticketQueryViewController:TicketQueryViewController?
    
    var loginWindowController:LoginWindowController!
    
    lazy var preferencesWindowController:NSWindowController = {
        let generalViewController = GeneralPreferenceViewController()
        let advanceViewController = AdvancedPreferenceViewController()
        let controllers = [generalViewController,advanceViewController]
        
        return MASPreferencesWindowController(viewControllers:controllers,title: "Preferences")
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
            NSNotificationCenter.defaultCenter().postNotificationName(NSWindowDidMoveNotification, object:self.window)
        }
        
        let titleView = aWindow.titleBarView
        let buttonPoint = NSMakePoint(85, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
        titleView.addSubview(self.loginButton)
        
        let segmentSize = NSMakeSize(120, 25)
        let segmentFrame = NSMakeRect(
            NSMidX(titleView.bounds) - (segmentSize.width / 2.0),
            NSMidY(titleView.bounds) - (segmentSize.height / 2.0),
            segmentSize.width, segmentSize.height)
        let segment = NSSegmentedControl(frame: segmentFrame)
        segment.segmentCount = 2
        segment.setLabel(TrainBook, forSegment: 0)
        segment.setLabel(TrainOrder, forSegment: 1)
//        segment.setLabel(TainTask, forSegment: 2)
        segment.selectedSegment = 0
        segment.segmentStyle = NSSegmentStyle.TexturedSquare
        segment.target = self
        segment.action = #selector(MainWindowController.segmentTab(_:))
        
        let searchFieldSize = NSMakeSize(150, 22)
        let searchFrame = NSMakeRect(
            NSMaxX(titleView.bounds) - (searchFieldSize.width + 20),
            NSMidY(titleView.bounds) - (searchFieldSize.height / 2.0),
            searchFieldSize.width, searchFieldSize.height)
        self.IPLabel.frame = searchFrame
        let searchField = self.IPLabel
        
        
        titleView.addSubview(segment)
        titleView.addSubview(searchField)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        let searchFieldConstraints1 = NSLayoutConstraint.constraintsWithVisualFormat("[searchField(120)]-20-|", options: .AlignAllBaseline, metrics: nil, views: ["searchField":searchField])
        NSLayoutConstraint.activateConstraints(searchFieldConstraints1)
        let searchFieldConstraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:[searchField(22)]-8-|", options: .AlignAllCenterX, metrics: nil, views: ["searchField":searchField])
        NSLayoutConstraint.activateConstraints(searchFieldConstraints2)
        
        let segmentConstraint1 = NSLayoutConstraint(item: segment, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: titleView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        let segmentConstraint2 = NSLayoutConstraint(item: segment, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: titleView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activateConstraints([segmentConstraint1,segmentConstraint2])
        
//	aWindow.bottomBarDrawingBlock = aWindow.titleBarDrawingBlock;
//    	aWindow.bottomBarHeight = aWindow.titleBarHeight;
//	NSView *titleBarView = aWindow.titleBarView;
        
        selectModule(TrainBook)
        
        self.window?.recalculateKeyViewLoop()
        
        //login notification
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MainWindowController.receiveDidSendLoginMessageNotification(_:)), name: DidSendLoginMessageNotification, object: nil)
    }
    
    func segmentTab(sender: NSSegmentedControl){
        selectModule(sender.labelForSegment(sender.selectedSegment)!)
    }
    
    func selectModule(moduleName:String){
        if(moduleName == TrainOrder){
            if orderQueryViewController == nil{
                orderQueryViewController = OrderViewController()
            }
            self.window?.contentView = orderQueryViewController!.view
        }
        else if(moduleName == TrainBook){
            if ticketQueryViewController == nil{
                ticketQueryViewController = TicketQueryViewController()
            }
            self.window?.contentView = ticketQueryViewController!.view
        }
    }
    
    func receiveDidSendLoginMessageNotification(note: NSNotification){
        print("receiveDidSendLoginMessageNotification")
        loginOut()
        login()
    }
    
    @IBAction func UserLogin(sender: NSButton){
        if !MainModel.isGetUserInfo{
            self.login()
        }
        else{
            var position:NSPoint = sender.bounds.origin
            position.y += sender.bounds.size.height + 5
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
    
    
    func login(){
        loginWindowController = LoginWindowController()
        
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

extension MainWindowController: NSWindowDelegate {
    func windowWillEnterFullScreen(notification: NSNotification) {
        let buttonPoint = NSMakePoint(20, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
    }
    
    func windowWillExitFullScreen(notification: NSNotification) {
        let buttonPoint = NSMakePoint(85, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
    }
}

