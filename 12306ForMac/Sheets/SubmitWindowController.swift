//
//  PreOrderWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/14.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class SubmitWindowController: NSWindowController{

    @IBOutlet weak var trainCodeLabel: NSTextField!
    @IBOutlet weak var trainDateLabel: NSTextField!
    @IBOutlet weak var trainTimeLabel: NSTextField!
    
    let service = Service()
    @IBOutlet weak var passengerTable: NSTableView!
    @IBOutlet weak var passengerImage: RandCodeImageView2!
    
    @IBOutlet var orderInfoView: NSView!
    @IBOutlet weak var preOrderView: GlassView!
    @IBOutlet weak var orderIdView: GlassView!
    
    @IBOutlet weak var loadingTipView: GlassView!
    @IBOutlet weak var loadingTip: NSTextField!
    @IBOutlet weak var loadingTipBar: NSProgressIndicator!
    
    @IBOutlet weak var orderId: NSTextField!
    @IBOutlet weak var totalPriceLabel: NSTextField!
    
    @IBOutlet weak var errorFlashLabel: FlashLabel!
    
    @IBAction func FreshImage(sender: NSButton) {
        freshImage()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.switchViewFrom(nil, to: orderInfoView)
        self.freshOrderInfoView()
        
        self.loadImage()
    }
    
    func freshOrderInfoView(){
        let info = MainModel.selectedTicket!
        trainCodeLabel.stringValue = "\(info.TrainCode!) \(info.FromStationName!) - \(info.ToStationName!)"
        trainDateLabel.stringValue = "\(info.startTrainDateStr!)"
        trainTimeLabel.stringValue = "\(info.start_time!)~\(info.arrive_time!) 历时\(info.lishi!)"
        
        passengerTable.reloadData()
    }
    
    func switchViewFrom(oldView:NSView?,to newView: NSView) {
        if oldView != nil {
            oldView!.removeFromSuperview()
        }
        self.window?.setFrame(newView.frame, display: true, animate: true)
        self.window?.contentView?.addSubview(newView)
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
    
    
    func loadImage(){
        self.startLoadingTip("正在加载...")
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.stopLoadingTip()
        }
        
        let failureHandler = { (error:NSError) -> () in
            self.errorFlashLabel.show(translate(error), forDuration: 10, withFlash: false)
            self.stopLoadingTip()
        }
        service.preOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func freshImage(){
        self.startLoadingTip("正在加载...")
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.stopLoadingTip()
        }
        
        let failHandler = {(error:ErrorType) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = nil
            self.stopLoadingTip()
        }
        
        service.getPassCodeNewForPassenger().then({image in
            successHandler(image)
        }).error({error in
            failHandler(error)
        })
    }
    
    override var windowNibName: String{
        return "SubmitWindowController"
    }
    
    @IBAction func payButtonClicked(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    @IBAction func clickCheckOrderBtn(sender: NSButton) {
        self.switchViewFrom(orderInfoView, to: preOrderView)
    }
    
    @IBAction func okayButtonClicked(button:NSButton){
        
        if passengerImage.randCodeStr == nil {
            errorFlashLabel.show("请先选择验证码", forDuration: 0.1, withFlash: false)
            return
        }
        
        self.startLoadingTip("正在提交...")
        button.enabled = false
        
        let failureHandler = { (error:NSError) -> () in
            self.stopLoadingTip()
            button.enabled = true
            self.errorFlashLabel.show(translate(error), forDuration: 0.1, withFlash: false)
            self.freshImage()
        }
        
        let successHandler = {
            self.stopLoadingTip()
            button.enabled = true
            self.switchViewFrom(self.preOrderView, to: self.orderIdView)
            self.orderId.stringValue = MainModel.orderId!
            self.totalPriceLabel.stringValue = "¥\(MainModel.ticketPrice)"
        }
        
        let waitHandler = { (info:String)-> () in
            self.startLoadingTip(info)
        }
        
        service.orderFlowWith(passengerImage.randCodeStr!, success: successHandler, failure: failureHandler,wait: waitHandler)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}

// MARK: - NSTableViewDataSource
extension SubmitWindowController:NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return MainModel.selectPassengers.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return MainModel.selectPassengers[row]
    }
}
