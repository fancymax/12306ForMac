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
//    dynamic var hasOrder = true
    
    var orderList = [OrderDTO]()
    let service = Service()
    var loadingTipController = LoadingTipViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(PassengerSelectViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
    }
    
    override var nibName: String?{
        return "OrderViewController"
    }
    
    override func viewDidAppear() {
        if ((!hasQuery) && (MainModel.isGetUserInfo)) {
            queryNoCompleteOrder()
        }
    }
    
    @IBAction func queryOrder(sender: NSButton) {
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
                    let successHandler = {
                        MainModel.noCompleteOrderList.removeAll()
                        self.orderList.removeAll()
                        self.orderListTable.reloadData()
                        self.tips.show("取消订单成功", forDuration: 1, withFlash: false)
                        self.hasOrder = false
                    }
                    let failureHandler = {(error:NSError)->() in
                        self.tips.show(translate(error), forDuration: 1, withFlash: false)
                    }
                    self.service.cancelOrderWith(sequence_no, success: successHandler, failure:failureHandler)
                }
            }
        })
    }
    
    @IBAction func payOrder(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    func queryNoCompleteOrder(){
        self.orderList = [OrderDTO]()
        self.orderListTable.reloadData()
        
        if !MainModel.isGetUserInfo {
            NSNotificationCenter.defaultCenter().postNotificationName(DidSendLoginMessageNotification, object: nil)
            return
        }
        
        hasQuery = true
        self.loadingTipController.start(tip:"正在查询...")
        
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
