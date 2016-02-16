//
//  OrderViewController.swift
//  Train12306
//
//  Created by fancymax on 16/2/16.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class OrderViewController: NSViewController,NSTableViewDataSource {
    let service = Service()
    var orderList = [OrderDTOData]()
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!

    @IBOutlet weak var orderListTable: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.hidden = true
    }
    
    @IBAction func test(sender: NSButton) {
        let successHandler = {
            //如果成功 则从MainModel里获取数据
            self.orderList = MainModel.orderDTODataList!
            self.orderListTable.reloadData()
            
            //成功信息提示
            
            //停止提示信息旋转
            self.stopQueryTip()
        }
        
        let failHandler = {
            //失败信息提示
            
            //停止提示信息旋转
            self.stopQueryTip()
        }
        startQueryTip()
        service.GetHistoryOrder(successHandler,failHandler: failHandler)
        orderListTable.reloadData()
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
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView.tag == 1{
            return 2
        }
        else{
            return orderList.count
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        print("\(tableView.tag)")
        print("\(tableView.identifier)")
        if tableView.tag == 1{
            if row == 0{
                return "未完成订单"
            }
            else{
                return "已完成订单"
            }
        }
        return orderList[row]
    }
    
}
