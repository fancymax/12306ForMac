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
    let menuListIdentifier = "MenuList"
    let orderListIdentifier = "OrderList"
    let noCompleteOrderRow = 0
    let historyOrderRow = 1
    var loadingTipController = LoadingTipViewController(nibName:"LoadingTipViewController",bundle: nil)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
    }
    
    @IBAction func queryOrder(sender: NSButton) {
//        initDemoOrderList()
//        return
        
        if !MainModel.isGetUserInfo {
            tips.show("请先登录～", forDuration: 0.1, withFlash: false)
            return
        }
        
        self.loadingTipController.start(tip:"正在查询...")
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
            self.loadingTipController.stop()
        }

        let failureHandler = {
            //失败信息提示
            
            //停止提示信息旋转
            self.loadingTipController.stop()
        }
        service.queryHistoryOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func queryNoCompleteOrder(){
        let successHandler = {
            //如果成功 则从MainModel里获取数据
            self.orderList = MainModel.noCompleteOrderList
            self.orderListTable.reloadData()
            
            //停止提示信息旋转
            self.loadingTipController.stop()
        }

        let failureHandler = {
            //失败信息提示
            
            //停止提示信息旋转
            self.loadingTipController.stop()
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
