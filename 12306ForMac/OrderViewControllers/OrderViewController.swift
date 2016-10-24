//
//  OrderViewController.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class OrderViewController: NSViewController{
    @IBOutlet weak var orderListTable: NSTableView!
    @IBOutlet weak var payBtn: NSButton!
    
    var hasQuery = false
    dynamic var hasOrder = false
    
    var orderList = [OrderDTO]()
    let service = Service()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(PassengerSelectViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
    }
    
    override var nibName: String?{
        return "OrderViewController"
    }
    
    override func viewDidAppear() {
        if ((!hasQuery) && (MainModel.isGetUserInfo)) {
            queryAllOrder()
        }
    }
    
    @IBAction func queryOrder(sender: NSButton) {
        queryAllOrder()
    }
    
    func showTip(tip:String)  {
        DJTipHUD.showStatus(tip, fromView: self.view)
    }
    
    func startLoadingTip(tip:String)
    {
        DJLayerView.showStatus(tip, fromView: self.view)
    }
    
    func stopLoadingTip(){
        DJLayerView.dismiss()
    }
    
    func receiveLogoutMessageNotification(notification: NSNotification) {
        MainModel.noCompleteOrderList.removeAll()
        self.orderList.removeAll()
        self.orderListTable.reloadData()
        self.hasOrder = false
    }
    
    @IBAction func cancelOrder(sender: NSButton) {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        alert.messageText = "您确认取消订单吗？"
        alert.informativeText = "一天内3次取消订单，当日将不能再网上购票。"
        
        alert.addButtonWithTitle("确定")
        alert.addButtonWithTitle("取消")
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: { reponse in
            if reponse == NSAlertFirstButtonReturn {
                if let sequence_no = MainModel.noCompleteOrderList[0].sequence_no {
                    self.startLoadingTip("正在取消...")
        
                    let successHandler = {
                        MainModel.noCompleteOrderList.removeAll()
                        self.orderList = MainModel.historyOrderList
                        self.orderListTable.reloadData()
                        self.stopLoadingTip()
                        self.showTip("取消订单成功")
                        self.hasOrder = false
                    }
                    let failureHandler = {(error:NSError)->() in
                        self.stopLoadingTip()
                        self.showTip(translate(error))
                    }
                    self.service.cancelOrderWith(sequence_no, success: successHandler, failure:failureHandler)
                }
            }
        })
    }
    
    @IBAction func payOrder(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    func queryHistoryOrder(){
        self.startLoadingTip("正在查询...")
        
        let successHandler = {
            self.orderList.appendContentsOf(MainModel.historyOrderList)
            self.orderListTable.reloadData()
            
            self.stopLoadingTip()
        }
        
        let failureHandler = {
            self.stopLoadingTip()
        }
        service.queryHistoryOrderFlow((success: successHandler, failure: failureHandler))
    }
    
    func queryAllOrder(){
        if !MainModel.isGetUserInfo {
            NSNotificationCenter.defaultCenter().postNotificationName(DidSendLoginMessageNotification, object: nil)
            return
        }
        
        self.orderList = [OrderDTO]()
        self.orderListTable.reloadData()
        
        hasQuery = true
        self.startLoadingTip("正在查询...")
        
        let successHandler = {
            self.orderList = MainModel.noCompleteOrderList
            self.orderListTable.reloadData()
            
            self.stopLoadingTip()
            
            if self.orderList.count > 0 {
                self.hasOrder = true
            }
            else {
                self.hasOrder = false
            }
            
            self.queryHistoryOrder()
        }
        
        let failureHandler = {
            self.stopLoadingTip()
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
