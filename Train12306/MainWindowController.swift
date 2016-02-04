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
}

