//
//  OrderViewController.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class OrderViewController: NSViewController{
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    @IBOutlet weak var tips: FlashLabel!
    @IBOutlet weak var orderListTable: NSTableView!
    
    var orderList = [OrderDTO]()
    let service = Service()
    let menuListIdentifier = "MenuList"
    let orderListIdentifier = "OrderList"
    let noCompleteOrderRow = 0
    let historyOrderRow = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.hidden = true
    }
    
    @IBAction func queryOrder(sender: NSButton) {
        if !MainModel.isGetUserInfo {
            tips.show("请先登录～", forDuration: 0.1, withFlash: false)
            return
        }
        
        startQueryTip()
        
//        initDemoOrderList()
        
            queryNoCompleteOrder()
//            queryHistoryOrder()
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
    
    func queryHistoryOrder(){
        let successHandler = {
            //如果成功 则从MainModel里获取数据
            self.orderList = MainModel.historyOrderList
            self.orderListTable.reloadData()
            
            //停止提示信息旋转
            self.stopQueryTip()
        }

        let failureHandler = {
            //失败信息提示
            
            //停止提示信息旋转
            self.stopQueryTip()
        }
        service.queryHistoryOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func queryNoCompleteOrder(){
        let successHandler = {
            //如果成功 则从MainModel里获取数据
            self.orderList = MainModel.noCompleteOrderList
            self.orderListTable.reloadData()
            
            //停止提示信息旋转
            self.stopQueryTip()
        }

        let failureHandler = {
            //失败信息提示
            
            //停止提示信息旋转
            self.stopQueryTip()
        }
        service.queryNoCompleteOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func startQueryTip()
    {
        loadingSpinner.startAnimation(nil)
        loadingView.hidden = false
    }
    
    func stopQueryTip(){
        loadingSpinner.stopAnimation(nil)
        loadingView.hidden = true
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
