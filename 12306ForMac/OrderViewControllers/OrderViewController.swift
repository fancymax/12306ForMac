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
    
    var orderList = [OrderDTO]()
    let service = Service()
    var loadingTipController = LoadingTipViewController(nibName:"LoadingTipViewController",bundle: nil)!
    @IBOutlet weak var payBtn: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
        self.payBtn.enabled = false
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
        
        self.loadingTipController.start(tip:"正在查询...")
        queryNoCompleteOrder()
    }
    
    func initDemoOrderList(){
        var demoList = [OrderDTO]()
        for _ in 0..<5 {
            let demo = OrderDTO()
            demoList.append(demo)
        }
        self.orderList = demoList
        self.orderListTable.reloadData()
    }
    
    @IBAction func payOrder(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    func queryHistoryOrder(){
        
        let successHandler = {
            self.orderList = MainModel.historyOrderList
            self.orderListTable.reloadData()
            
            self.loadingTipController.stop()
        }

        let failureHandler = {
            self.loadingTipController.stop()
            
        }
        service.queryHistoryOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func queryNoCompleteOrder(){
        let successHandler = {
            self.orderList = MainModel.noCompleteOrderList
            self.orderListTable.reloadData()
            
            self.loadingTipController.stop()
            
            if self.orderList.count > 0 {
                self.payBtn.enabled = true
            }
            else {
                self.payBtn.enabled = false
            }
        }

        let failureHandler = {
            self.loadingTipController.stop()
            
            self.payBtn.enabled = false
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
