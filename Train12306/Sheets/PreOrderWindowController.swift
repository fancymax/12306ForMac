//
//  PreOrderWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/14.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class PreOrderWindowController: NSWindowController,NSTableViewDataSource,NSTableViewDelegate{

    let service = Service()
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
    
    @IBAction func FreshImage(sender: NSButton) {
        freshImage()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        orderTipLabel.hidden = true
        
        preOrderView.hidden = false
        orderIdView.hidden = true
        
        let trainInfo = MainModel.selectedTicket
        orderTicketLabel.stringValue =  trainInfo!.startTrainDateStr! + " " + trainInfo!.TrainCode!
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
        return MainModel.selectPassengers.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return MainModel.selectPassengers[row]
    }
    
    func loadImage(){
        self.startLoadingTip("正在加载...")
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.stopLoadingTip()
            self.orderTicketLabel.stringValue += " ¥\(MainModel.ticketPrice)"
        }
        
        let failureHandler = {
            self.stopLoadingTip()
        }
        service.preOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func freshImage(){
        self.startLoadingTip("正在加载...")
        let handler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.stopLoadingTip()
        }
        
        service.getPassCodeNewForPassenger().then({image in
            handler(image)
        })
    }
    
    override var windowNibName: String{
        return "PreOrderWindowController"
    }
    
    @IBAction func payButtonClicked(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    @IBAction func okayButtonClicked(button:NSButton){
        self.startLoadingTip("正在提交...")
        button.enabled = false
        
        let failureHandler = {
            self.stopLoadingTip()
            button.enabled = true
            self.freshImage()
        }
        
        let successHandler = {
            self.stopLoadingTip()
            button.enabled = true
            self.preOrderView.hidden = true
            self.orderIdView.hidden = false
            self.orderTipLabel.hidden = false
            self.orderId.stringValue = MainModel.orderId!
        }
        
        service.orderFlowWith(passengerImage.randCodeStr!, success: successHandler, failure: failureHandler)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}
