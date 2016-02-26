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
    @IBOutlet weak var menuListTable: NSTableView!
    
    var orderList = [OrderDTOData]()
    let service = Service()
    let menuListIdentifier = "MenuList"
    let orderListIdentifier = "OrderList"
    let unfinishOrderRow = 0
    let orderHistoryRow = 1

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
        
        queryHistoryOrder()
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
        if tableView.identifier == menuListIdentifier{
            return 2
        }
        else{
            return orderList.count
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableView.identifier == menuListIdentifier{
            if row == unfinishOrderRow{
                return "未完成订单"
            }
            else{
                return "已完成订单"
            }
        }
        else{
            return orderList[row]
        }
    }
}

// MARK: - NSTableViewDelegate for MenuList
extension OrderViewController: NSTableViewDelegate{
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if(menuListTable.selectedRow == unfinishOrderRow){
            self.orderList = MainModel.unfinishOrderList
            self.orderListTable.reloadData()
        }
        else{
            self.orderList = MainModel.historyOrderList
            self.orderListTable.reloadData()
        }
    }
}
