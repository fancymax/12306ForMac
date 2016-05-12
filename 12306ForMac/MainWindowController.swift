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
    var taskViewController:TaskViewController?
    
    var loginWindowController:LoginWindowController!
    
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
        let buttonPoint = NSMakePoint(80, 5)
        self.loginButton.setFrameOrigin(buttonPoint)
        titleView.addSubview(self.loginButton)
        
        let segmentSize = NSMakeSize(120, 25)
        let segmentFrame = NSMakeRect(
            NSMidX(titleView.bounds) - (segmentSize.width / 2.0),
            NSMidY(titleView.bounds) - (segmentSize.height / 2.0),
            segmentSize.width, segmentSize.height)
        let segment = NSSegmentedControl(frame: segmentFrame)
        segment.segmentCount = 3
        segment.setLabel("车票预订", forSegment: 0)
        segment.setLabel("抢票任务", forSegment: 1)
        segment.setLabel("订单查询", forSegment: 2)
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
        
        selectModule(0)
        
        self.window?.recalculateKeyViewLoop()
        
        //login notification
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MainWindowController.receiveDidSendLoginMessageNotification(_:)), name: DidSendLoginMessageNotification, object: nil)
        
        let service = Service()
        service.getWanIP({ip in
            self.IPLabel.stringValue = ip
        })
    }
    
    func segmentTab(sender: NSSegmentedControl){
        selectModule(sender.selectedSegment)
    }
    
    func selectModule(moduleIndex:Int){
        if(moduleIndex == 2){
            if orderQueryViewController == nil{
                orderQueryViewController = OrderViewController()
            }
            self.window?.contentView = orderQueryViewController!.view
        }
        else if(moduleIndex == 0){
            if ticketQueryViewController == nil{
                ticketQueryViewController = TicketQueryViewController()
            }
            self.window?.contentView = ticketQueryViewController!.view
        }
        else{
            if taskViewController == nil{
                taskViewController = TaskViewController()
            }
            self.window?.contentView = taskViewController!.view
        }
    }
    
    func receiveDidSendLoginMessageNotification(note: NSNotification){
        print("receiveDidSendLoginMessageNotification")
        loginOut()
        login()
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
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
    
    func loginOut(){
        MainModel.isGetUserInfo = false
        MainModel.isGetPassengersInfo = false
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
    
}

