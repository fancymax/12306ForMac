//
//  PreOrderWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/14.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class SubmitWindowController: BaseWindowController{

    @IBOutlet weak var trainCodeLabel: NSTextField!
    @IBOutlet weak var trainDateLabel: NSTextField!
    @IBOutlet weak var trainTimeLabel: NSTextField!
    
    @IBOutlet weak var passengerTable: NSTableView!
    @IBOutlet weak var passengerImage: RandCodeImageView2!
    
    @IBOutlet var orderInfoView: NSView!
    @IBOutlet weak var preOrderView: GlassView!
    @IBOutlet weak var orderIdView: GlassView!
    
    @IBOutlet weak var orderId: NSTextField!
    
    var isAutoSubmit = false
    var isSubmitting = false
    
    override var windowNibName: String{
        return "SubmitWindowController"
    }
    
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
        
        passengerTable.reloadData()
    }
    
    func switchViewFrom(_ oldView:NSView?,to newView: NSView) {
        if oldView != nil {
            oldView!.removeFromSuperview()
        }
        self.window?.setFrame(newView.frame, display: true, animate: true)
        self.window?.contentView?.addSubview(newView)
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
        Service.sharedInstance.preOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func freshImage(){
        self.passengerImage.clearRandCodes()
        
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.image = image
        }
        
        let failHandler = {(error:NSError) -> () in
            self.showTip(translate(error as NSError))
        }
        
        Service.sharedInstance.getPassCodeNewForPassenger().then{ image in
            successHandler(image)
        }.catch{ error in
            failHandler(error as NSError)
        }
    }
    
    func orderFlowWithoutRandCode() {
        let failureHandler = { (error:NSError) -> () in
            self.stopLoadingTip()
            self.isSubmitting = false
            self.showTip(translate(error))
        }
        
        let successHandler = {
            self.stopLoadingTip()
            self.isSubmitting = false
            self.switchViewFrom(self.orderInfoView, to: self.orderIdView)
            self.orderId.stringValue = MainModel.orderId!
        }
        
        let waitHandler = { (info:String)-> () in
            self.startLoadingTip(info)
        }
        
        Service.sharedInstance.orderFlowWithoutRandCode(success: successHandler, failure: failureHandler,wait: waitHandler)
    }
    
    @IBAction func clickCheckOrder(_ sender: NSButton) {
        self.startLoadingTip("正在提交...")
        if isSubmitting {
            return
        }
        isSubmitting = true
        
        let failureHandler = { (error:NSError) -> () in
            self.stopLoadingTip()
            self.showTip(translate(error))
        }
        
        let successHandler = {(ifShowRandCode:Bool)->() in
            if ifShowRandCode {
                self.stopLoadingTip()
                self.isSubmitting = false
                self.switchViewFrom(self.orderInfoView, to: self.preOrderView)
            }
            else {
                self.orderFlowWithoutRandCode()
            }
        }
        Service.sharedInstance.checkOrderFlow(success: successHandler, failure: failureHandler)
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
        }
        
        let waitHandler = { (info:String)-> () in
            self.startLoadingTip(info)
        }
        
        Service.sharedInstance.orderFlowWith(passengerImage.randCodeStr!, success: successHandler, failure: failureHandler,wait: waitHandler)
    }
    
    @IBAction func clickCancel(_ button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    @IBAction func clickRateInAppstore(_ button:NSButton){
        NSWorkspace.shared().open(URL(string: "macappstore://itunes.apple.com/us/app/ding-piao-zhu-shou/id1163682213?l=zh&ls=1&mt=12")!)
        dismissWithModalResponse(NSModalResponseCancel)
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
