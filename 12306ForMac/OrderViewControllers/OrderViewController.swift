//
//  OrderViewController.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class OrderViewController: BaseViewController{
    @IBOutlet weak var orderListTable: NSTableView!
    @IBOutlet weak var payBtn: NSButton!
    
    var hasQuery = false
    dynamic var hasOrder = false
    lazy var payWindowController:PayWindowController = PayWindowController()
    
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
    
    @IBAction func clickQueryTicket(_ sender: AnyObject?) {
        queryAllOrder()
    }
    
    @IBAction func clickQueryOrder(_ sender: AnyObject?) {
        queryAllOrder()
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
        logger.info("-> pay")
        
        payWindowController = PayWindowController()
        
        if let window = self.view.window {
            window.beginSheet(payWindowController.window!, completionHandler: {response in
                if response == NSModalResponseOK{
                    logger.info("<- pay")
                    self.queryAllOrder()
                }
            })
        }
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
    
// MARK: - Menu Action
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.title.contains("刷新") {
            return true
        }
        if orderList.count == 0 {
            return false
        }
        
        return true
    }
    
    @IBAction func clickShareInfo(_ sender:AnyObject?) {
        let generalPasteboard = NSPasteboard.general()
        generalPasteboard.clearContents()
        let ticket = orderList[orderListTable.selectedRow]
        let shareInfo = "我已预订 \(ticket.start_train_date_page!) \(ticket.station_train_code!) \(ticket.startEndStation) \(ticket.seat_type_name!)(\(ticket.whereToSeat))"
        generalPasteboard.setString(shareInfo, forType:NSStringPboardType)
        
        showTip("车票信息已生成,可复制到其他App")
    }
    
    @IBAction func clickAdd2Calendar(_ sender:AnyObject?){
        let ticket = orderList[orderListTable.selectedRow]
        
        let eventTitle = "\(ticket.station_train_code!) \(ticket.startEndStation) \(ticket.seat_type_name!)(\(ticket.whereToSeat))"
        let endDate = ticket.startTrainDate!
        let startDate = endDate.addingTimeInterval(-7200)
        
        let isSuccess = CalendarManager.sharedInstance.createEvent(title:eventTitle,startDate:startDate,endDate:endDate)
        
        if !isSuccess {
            self.showTip("添加日历失败,请到 系统偏好设置->安全性与隐私->隐私->日历 允许本程序的访问权限。")
        }
        else {
            self.showTip("添加日历成功。")
        }
    }
    
    @IBAction func clickRefund(_ sender:AnyObject?){
        
    }
}

// MARK: - NSTableViewDataSource
extension OrderViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
            return orderList.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
            return orderList[row]
    }
}
