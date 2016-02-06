//
//  MainWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController,LoginPopoverDelegate{
    var loginWindowController = LoginWindowController()
    
    @IBOutlet weak var stackContentView: NSStackView!
    @IBOutlet weak var loginButton: LoginButton!
    
    var normalSearchViewController: NormalSearchViewController?
    var ticketTableViewController: TicketTableViewController?
    var disclosureViewController: DisclosureViewController?
    
    var loginPopover:NSPopover?
    
    @IBAction func UserLogin(sender: NSButton){
        if !MainModel.isGetUserInfo{
            self.login()
        }
        else{
            self.createLoginPopover()
            let cellRect = sender.bounds
            self.loginPopover?.showRelativeToRect(cellRect, ofView: sender, preferredEdge: .MaxY)
        }
    }
    
    func didLoginOut() {
        loginButton.title = "登录 ▾"
        login()
    }
    
    func login(){
        loginWindowController = LoginWindowController()
        
        if let window = self.window {
            //赋值原始的用户名，密码
            window.beginSheet(loginWindowController.window!) {
                if $0 == NSModalResponseOK{
                    self.loginButton.title = MainModel.user.realName!
                }
            }
        }
    }
    
    func createLoginPopover(){
        var myPopover = self.loginPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            let cp = LoginPopoverViewController()
            cp.delegate = self
            myPopover!.contentViewController = cp
            myPopover!.appearance = NSAppearance(named: "NSAppearanceNameAqua")
            myPopover!.animates = true
            myPopover!.behavior = NSPopoverBehavior.Transient
        }
        self.loginPopover = myPopover
    }
    
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
        segment.segmentCount = 2
        segment.setLabel("订票", forSegment: 0)
        segment.setLabel("订单", forSegment: 1)
        segment.selectedSegment = 0
        segment.segmentStyle = NSSegmentStyle.TexturedSquare
        segment.target = self
        segment.action = Selector("test:")
        
        let searchFieldSize = NSMakeSize(150, 22)
        let searchFrame = NSMakeRect(
            NSMaxX(titleView.bounds) - (searchFieldSize.width + 20),
            NSMidY(titleView.bounds) - (searchFieldSize.height / 2.0),
            searchFieldSize.width, searchFieldSize.height)
        let searchField = NSSearchField(frame: searchFrame)
        
        titleView.addSubview(segment)
        titleView.addSubview(searchField)
        
//	aWindow.bottomBarDrawingBlock = aWindow.titleBarDrawingBlock;
//    	aWindow.bottomBarHeight = aWindow.titleBarHeight;
//	NSView *titleBarView = aWindow.titleBarView;
        
        self.normalSearchViewController = NormalSearchViewController(nibName: "NormalSearchViewController",bundle: nil)
        self.ticketTableViewController = TicketTableViewController(nibName: "TicketTableViewController",bundle: nil)
        self.normalSearchViewController?.ticketTableDelegate = self.ticketTableViewController
        self.disclosureViewController = DisclosureViewController(nibName:"DisclosureViewController", bundle:nil)
        
        self.stackContentView.addView(normalSearchViewController!.view, inGravity:.Top)
        self.stackContentView.addView(disclosureViewController!.view, inGravity: .Top)
        self.stackContentView.addView(ticketTableViewController!.view, inGravity: .Top)
        
        self.stackContentView.orientation = .Vertical
        self.stackContentView.alignment = .CenterX
        self.stackContentView.spacing = 0
        
        self.window?.recalculateKeyViewLoop()
    }
    
    func test(sender: NSSegmentedControl){
        if(sender.selectedSegment == 1){
            self.stackContentView.removeView(normalSearchViewController!.view)
            self.stackContentView.removeView(disclosureViewController!.view)
            self.stackContentView.removeView(ticketTableViewController!.view)
        }
        else{
            self.stackContentView.addView(normalSearchViewController!.view, inGravity:.Top)
            self.stackContentView.addView(disclosureViewController!.view, inGravity: .Top)
            self.stackContentView.addView(ticketTableViewController!.view, inGravity: .Top)
        }
        print("test")
    }
    
    
}

