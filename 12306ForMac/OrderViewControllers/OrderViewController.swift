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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderViewController.recvLogoutNotification(_:)), name: NSNotification.Name.App.DidLogout, object: nil)
    }
    
    override var nibName: String?{
        return "OrderViewController"
    }
    
    override func viewDidAppear() {
        if ((!hasQuery) && (MainModel.isGetUserInfo)) {
            queryAllOrder()
        }
    }
    
    @IBAction func queryOrder(_ sender: NSButton) {
        queryAllOrder()
    }
    
    func showTip(_ tip:String)  {
        DJTipHUD.showStatus(tip, from: self.view)
    }
    
    func startLoadingTip(_ tip:String)
    {
        DJLayerView.showStatus(tip, from: self.view)
    }
    
    func stopLoadingTip(){
        DJLayerView.dismiss()
    }
    
    func recvLogoutNotification(_ notification: Notification) {
        MainModel.noCompleteOrderList.removeAll()
        self.orderList.removeAll()
        self.orderListTable.reloadData()
        self.hasOrder = false
    }
    
    @IBAction func cancelOrder(_ sender: NSButton) {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.critical
        alert.messageText = "您确认取消订单吗？"
        alert.informativeText = "一天内3次取消订单，当日将不能再网上购票。"
        
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        alert.beginSheetModal(for: self.view.window!, completionHandler: { reponse in
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
                    Service.sharedInstance.cancelOrderWith(sequence_no, success: successHandler, failure:failureHandler)
                }
            }
        })
    }
    
    @IBAction func payOrder(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    func queryHistoryOrder(){
        self.startLoadingTip("正在查询...")
        
        let successHandler = {
            self.orderList.append(contentsOf: MainModel.historyOrderList)
            self.orderListTable.reloadData()
            
            self.stopLoadingTip()
        }
        
        let failureHandler = {(error:NSError) -> () in
            self.stopLoadingTip()
            self.showTip(translate(error))
        }
        Service.sharedInstance.queryHistoryOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func queryAllOrder(){
        if !MainModel.isGetUserInfo {
            NotificationCenter.default.post(name: Notification.Name.App.DidLogin, object: nil)
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
        Service.sharedInstance.queryNoCompleteOrderFlow(success: successHandler, failure: failureHandler)
    }
}

// MARK: - NSTableViewDataSource for MenuList and OrderList
extension OrderViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
            return orderList.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
            return orderList[row]
    }
}
