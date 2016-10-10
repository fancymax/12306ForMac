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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receiveLogoutMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendLogoutMessageNotification), object: nil)
    }
    
    override var nibName: String?{
        return "OrderViewController"
    }
    
    override func viewDidAppear() {
        if ((!hasQuery) && (MainModel.isGetUserInfo)) {
            queryNoCompleteOrder()
        }
    }
    
    @IBAction func queryOrder(_ sender: NSButton) {
        queryNoCompleteOrder()
    }
    
    
    func receiveLogoutMessageNotification(_ notification: Notification) {
        
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
    
    @IBAction func payOrder(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    func queryNoCompleteOrder(){
        self.orderList = [OrderDTO]()
        self.orderListTable.reloadData()
        
        if !MainModel.isGetUserInfo {
            NotificationCenter.default.post(name: Notification.Name(rawValue: DidSendLoginMessageNotification), object: nil)
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
            } else {
                self.hasOrder = false
            }
        }

        let failureHandler = {
            self.loadingTipController.stop()
            self.hasOrder = false
        }
        service.queryNoCompleteOrderFlow(successHandler, failure: failureHandler)
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
