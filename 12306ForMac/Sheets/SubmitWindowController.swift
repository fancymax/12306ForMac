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
    @IBOutlet weak var trainPriceLabel: NSTextField!
    
    let service = Service()
    @IBOutlet weak var passengerTable: NSTableView!
    @IBOutlet weak var passengerImage: RandCodeImageView2!
    
    @IBOutlet var orderInfoView: NSView!
    @IBOutlet weak var preOrderView: GlassView!
    @IBOutlet weak var orderIdView: GlassView!
    
    @IBOutlet weak var orderId: NSTextField!
    @IBOutlet weak var totalPriceLabel: NSTextField!
    
    var isAutoSubmit = false
    var isSubmitting = false
    
    @IBAction func FreshImage(_ sender: NSButton) {
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
        if let dateStr = MainModel.trainDate {
            trainDateLabel.stringValue = "\(G_Convert2StartTrainDateStr(dateStr))"
        }
        trainTimeLabel.stringValue = "\(info.start_time!)~\(info.arrive_time!) 历时\(info.lishi!)"
        trainPriceLabel.stringValue = "¥\(MainModel.ticketPrice)"
        
        passengerTable.reloadData()
    }
    
    func switchViewFrom(_ oldView:NSView?,to newView: NSView) {
        if oldView != nil {
            oldView!.removeFromSuperview()
        }
        self.window?.setFrame(newView.frame, display: true, animate: true)
        self.window?.contentView?.addSubview(newView)
    }
    
    func startLoadingTip(_ tip:String)
    {
        DJLayerView.showStatus(tip, from: self.window?.contentView)
    }
    
    func stopLoadingTip(){
        DJLayerView.dismiss()
    }
    
    func showTip(_ tip:String){
        DJTipHUD.showStatus(tip, from: self.window?.contentView)
    }
    
    func loadImage(){
        let autoSummitHandler = {(image:NSImage)->() in
            self.switchViewFrom(self.orderInfoView, to: self.preOrderView)
            self.startLoadingTip("自动打码...")
            
            Dama.sharedInstance.dama(AdvancedPreferenceManager.sharedInstance.damaUser,
                password: AdvancedPreferenceManager.sharedInstance.damaPassword,
                ofImage: image,
                success: {imageCode in
                    self.stopLoadingTip()
                    self.passengerImage.drawDamaCodes(imageCode)
                    self.clickOK(nil)
                },
            
                failure: {error in
                    self.stopLoadingTip()
                    self.showTip(translate(error))
                })
            
        }
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            if ((self.isAutoSubmit)&&(AdvancedPreferenceManager.sharedInstance.isUseDama)) {
                autoSummitHandler(image)
            }
        }
        
        let failureHandler = { (error:NSError) -> () in
            self.showTip(translate(error))
        }
        service.preOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func freshImage(){
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
        }
        
        let failHandler = {(error:Error) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = nil
        }
        
        service.getPassCodeNewForPassenger().then{ image in
            successHandler(image)
        }.catch{ error in
            failHandler(error)
        }
    }
    
    override var windowNibName: String{
        return "SubmitWindowController"
    }
    
    @IBAction func clickPay(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
    @IBAction func clickCheckOrder(_ sender: NSButton) {
        self.switchViewFrom(orderInfoView, to: preOrderView)
    }
    
    @IBAction func clickOK(_ sender:AnyObject?){
        
        if passengerImage.randCodeStr == nil {
            self.showTip("请先选择验证码")
            return
        }
        
        self.startLoadingTip("正在提交...")
        if isSubmitting {
            return
        }
        
        isSubmitting = true
        
        let failureHandler = { (error:NSError) -> () in
            self.stopLoadingTip()
            self.isSubmitting = false
            self.showTip(translate(error))
            self.freshImage()
        }
        
        let successHandler = {
            self.stopLoadingTip()
            self.isSubmitting = false
            self.switchViewFrom(self.preOrderView, to: self.orderIdView)
            self.orderId.stringValue = MainModel.orderId!
            self.totalPriceLabel.stringValue = "¥\(MainModel.ticketPrice)"
        }
        
        let waitHandler = { (info:String)-> () in
            self.startLoadingTip(info)
        }
        
        service.orderFlowWith(passengerImage.randCodeStr!, success: successHandler, failure: failureHandler,wait: waitHandler)
    }
    
    @IBAction func clickCancel(_ button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func dismissWithModalResponse(_ response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}

// MARK: - NSTableViewDataSource
extension SubmitWindowController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MainModel.selectPassengers.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return MainModel.selectPassengers[row]
    }
}
