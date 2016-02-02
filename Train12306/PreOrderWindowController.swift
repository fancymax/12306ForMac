//
//  PreOrderWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/14.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class PreOrderWindowController: NSWindowController,NSTableViewDataSource,NSTableViewDelegate{

    var trainInfo:QueryLeftNewDTO?
    @IBOutlet weak var orderTicketLabel: NSTextField!
    @IBOutlet weak var passengerTable: NSTableView!
    @IBOutlet weak var passengerImage: RandCodeImageView!
    
    @IBOutlet weak var orderTipLabel: NSTextField!
    
    @IBOutlet weak var preOrderView: GlassView!
    @IBOutlet weak var orderIdView: GlassView!
    
    @IBOutlet weak var loadingTipView: GlassView!
    @IBOutlet weak var loadingTip: NSTextField!
    @IBOutlet weak var loadingTipBar: NSProgressIndicator!
    
    @IBOutlet weak var orderId: NSTextField!
    
    let service = HTTPService()
    
    @IBAction func FreshImage(sender: NSButton) {
        freshImage()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        orderTipLabel.hidden = true
        
        preOrderView.hidden = false
        orderIdView.hidden = true
        
        let dateStr = ""
        orderTicketLabel.stringValue =  dateStr + " " + trainInfo!.TrainCode!
        + " " + trainInfo!.FromStationName! + " " + trainInfo!.start_time! + "-" + trainInfo!.ToStationName! + " " + trainInfo!.arrive_time!
        
        loadImage()
        passengerTable.reloadData()
    }
    
    func startLoadingTip(tip:String)
    {
        loadingTipBar.startAnimation(nil)
        loadingTip.stringValue = tip
        loadingTipView.hidden = false
    }
    
    func stopLoadingTip(){
        loadingTipBar.stopAnimation(nil)
        loadingTipView.hidden = true
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        print("select p count = \(MainModel.selectPassengers.count)")
        return MainModel.selectPassengers.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        print("row = \(row) name = \(MainModel.selectPassengers[row].passenger_name)")
        return MainModel.selectPassengers[row]
    }
    
    func loadImage(){
        self.startLoadingTip("正在加载...")
        let handler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.stopLoadingTip()
            self.orderTicketLabel.stringValue += " 总票价:\(MainModel.ticketPrice)元"
        }
//        service.getLeftTicketInit()  //??不确定是否需要定期调用这个接口
        service.getPreOrderImage(handler, failHandler: {})
    }
    
    func freshImage(){
        self.startLoadingTip("正在加载...")
        let handler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.stopLoadingTip()
        }
        
        let getImageOperation = service.getPassCodeNewForPassenger(successHandler: handler, failHandler:{})
        service.shareHTTPManager.operationQueue.addOperations([getImageOperation], waitUntilFinished: false)
    }
    
    override var windowNibName: String{
        return "PreOrderWindowController"
    }
    
    @IBAction func okayButtonClicked(button:NSButton){
        self.startLoadingTip("正在提交...")
        
        button.enabled = false
        //如果失败了，从哪个流程开始全部重新加载
        let failHandler = {
            self.stopLoadingTip()
            button.enabled = true
            self.freshImage()
        }
        
        //成功了就显示订单界面，并提示付款
        let successHandler = {
            self.stopLoadingTip()
            button.enabled = true
            self.preOrderView.hidden = true
            self.orderIdView.hidden = false
            self.orderTipLabel.hidden = false
            self.orderId.stringValue = MainModel.orderId!
        }
        
        service.order(passengerImage.randCodeStr!, successHandler: successHandler, failHandler: failHandler)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}
