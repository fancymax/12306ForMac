//
//  OrderViewController.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class OrderViewController: NSViewController{
    @IBOutlet weak var tips: FlashLabel!
    @IBOutlet weak var orderListTable: NSTableView!
    @IBOutlet weak var payBtn: NSButton!
    @IBOutlet weak var cancelOrderbtn: NSButton!
    
    var hasQuery = false
    dynamic var hasOrder = false
    
    var orderList = [OrderDTO]()
    let service = Service()
    var loadingTipController = LoadingTipViewController(nibName:"LoadingTipViewController",bundle: nil)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(PassengerSelectViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
    }
    
    override func viewDidAppear() {
        if ((!hasQuery) && (MainModel.isGetUserInfo)) {
            queryNoCompleteOrder()
        }
    }
    
    @IBAction func queryOrder(sender: NSButton) {
//        initDemoOrderList()
//        return
        
        self.orderList = [OrderDTO]()
        self.orderListTable.reloadData()
        
        if !MainModel.isGetUserInfo {
            NSNotificationCenter.defaultCenter().postNotificationName(DidSendLoginMessageNotification, object: nil)
            return
        }
        
        hasQuery = true
        self.loadingTipController.start(tip:"正在查询...")
        queryNoCompleteOrder()
    }
    
    
    func receiveLogoutMessageNotification(notification: NSNotification) {
        
    }
    
    func initDemoOrderList(){
        var demoList = [OrderDTO]()
        for _ in 0..<5 {
            let demo = OrderDTO()
            demoList.append(demo)
        }
        self.hasOrder = false
        self.orderList = demoList
        self.orderListTable.reloadData()
    }
    
    @IBAction func payOrder(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
//    func queryHistoryOrder(){
//        
//        let successHandler = {
//            self.orderList = MainModel.historyOrderList
//            self.orderListTable.reloadData()
//            
//            self.loadingTipController.stop()
//        }
//
//        let failureHandler = {
//            self.loadingTipController.stop()
//            
//        }
//        service.queryHistoryOrderFlow(success: successHandler, failure: failureHandler)
//    }
    
    func queryNoCompleteOrder(){
        let successHandler = {
            self.orderList = MainModel.noCompleteOrderList
            self.orderListTable.reloadData()
            
            self.loadingTipController.stop()
            
            if self.orderList.count > 0 {
                self.hasOrder = true
            }
            else {
                self.hasOrder = false
            }
        }

        let failureHandler = {
            self.loadingTipController.stop()
            self.hasOrder = false
        }
        service.queryNoCompleteOrderFlow(success: successHandler, failure: failureHandler)
    }
}

// MARK: - NSTableViewDataSource for MenuList and OrderList
extension OrderViewController: NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
            return orderList.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
            return orderList[row]
    }
}
