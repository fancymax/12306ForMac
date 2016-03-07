//
//  MainWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController{
    @IBOutlet weak var stackContentView: NSStackView!
    @IBOutlet weak var loginButton: LoginButton!
    
    var normalSearchViewController: NormalSearchViewController?
    var ticketTableViewController: TicketTableViewController?
    var disclosureViewController: DisclosureViewController?
    
    var splitViewController:OrderViewController?
    
    var loginWindowController = LoginWindowController()
    var loginPopover:NSPopover?
    
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
        segment.setLabel("车票预订", forSegment: 0)
        segment.setLabel("订单查询", forSegment: 1)
        segment.selectedSegment = 0
        segment.segmentStyle = NSSegmentStyle.TexturedSquare
        segment.target = self
        segment.action = Selector("segmentTab:")
        
        let searchFieldSize = NSMakeSize(150, 22)
        let searchFrame = NSMakeRect(
            NSMaxX(titleView.bounds) - (searchFieldSize.width + 20),
            NSMidY(titleView.bounds) - (searchFieldSize.height / 2.0),
            searchFieldSize.width, searchFieldSize.height)
        let searchField = NSSearchField(frame: searchFrame)
        
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
        
        //login notification
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("receiveDidSendLoginMessageNotification:"), name: DidSendLoginMessageNotification, object: nil)
    }
    
    func segmentTab(sender: NSSegmentedControl){
        if(sender.selectedSegment == 1){
            self.stackContentView.removeView(normalSearchViewController!.view)
            self.stackContentView.removeView(disclosureViewController!.view)
            self.stackContentView.removeView(ticketTableViewController!.view)
            
            if splitViewController == nil{
                splitViewController = OrderViewController()
            }
            
            self.stackContentView.addView(splitViewController!.view,inGravity:.Top)
        }
        else{
            self.stackContentView.removeView(splitViewController!.view)
            
            self.stackContentView.addView(normalSearchViewController!.view, inGravity:.Top)
            self.stackContentView.addView(disclosureViewController!.view, inGravity: .Top)
            self.stackContentView.addView(ticketTableViewController!.view, inGravity: .Top)
        }
    }
    
    func receiveDidSendLoginMessageNotification(note: NSNotification){
        print("receiveDidSendLoginMessageNotification")
        didLoginOut()
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
}

// MARK: - LoginPopoverDelegate
extension MainWindowController: LoginPopoverDelegate{
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
            window.beginSheet(loginWindowController.window!) {
                if $0 == NSModalResponseOK{
                    self.loginButton.title = MainModel.realName
                }
            }
        }
    }
    
    func createLoginPopover(){
        if(self.loginPopover == nil){
            let popover = NSPopover()
            let controller = LoginPopoverViewController()
            controller.delegate = self
            popover.contentViewController = controller
            popover.appearance = NSAppearance(named: "NSAppearanceNameAqua")
            popover.animates = true
            popover.behavior = NSPopoverBehavior.Transient
            self.loginPopover = popover
        }
    }
    
}

