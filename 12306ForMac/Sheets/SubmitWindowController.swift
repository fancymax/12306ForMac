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
    
    @IBOutlet weak var orderInfoView: NSView!
    @IBOutlet weak var preOrderView: GlassView!
    @IBOutlet weak var orderIdView: GlassView!
    @IBOutlet weak var submitOrderBtn: NSButton!
    
    private var spaceKeyboardMonitor:Any!
    
    @IBOutlet weak var orderInfoCloseButton: NSButton!
    @IBOutlet weak var orderInfoCheckOrderButton: NSButton!
    @IBOutlet weak var orderInfoExcludeButton: NSButton!
    
    @IBOutlet weak var preOrderCloseButton: NSButton!
    @IBOutlet weak var preOrderOkButton: NSButton!
    @IBOutlet weak var preOrderExcludeButton: NSButton!
    
    @IBOutlet weak var orderId: NSTextField!
    
    var isAutoSubmit = false
    var isSubmitting = false
    var ifShowCode = true
    var isCancel = false
    
    weak var timer:Timer?
    
    override var windowNibName: String{
        return "SubmitWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.switchViewFrom(nil, to: orderInfoView)
        self.freshOrderInfoView()
        
        self.preOrderFlow()
        
        if isAutoSubmit {
            if !ifShowCode {
                let origin = orderInfoCheckOrderButton.frame.origin
                orderInfoCheckOrderButton.isHidden = true
                orderInfoCloseButton.title = "取消自动"
                orderInfoCloseButton.setFrameOrigin(origin)
            }
        }
        else {
            orderInfoExcludeButton.isHidden = true
            preOrderExcludeButton.isHidden = true
        }
        
        //增加对Space按键的支持
        spaceKeyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: NSKeyDownMask) { [weak self] (theEvent) -> NSEvent? in
            //Space Key
            if (theEvent.keyCode == 49){
                if let weakSelf = self {
                    weakSelf.clickNext(nil)
                }
                return nil
            }
            return theEvent
        }
    }
    
// MARK: - custom function
    
    override func dismissWithModalResponse(_ response:NSModalResponse)
    {
        if window != nil {
            if window!.sheetParent != nil {
                window!.sheetParent!.endSheet(window!,returnCode: response)
                NSEvent.removeMonitor(spaceKeyboardMonitor!)
            }
        }

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
    
    func dama(image:NSImage) {
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
    
    func preOrderFlow(){
        self.startLoadingTip("获取验证码...")
        if isSubmitting {
            return
        }
        isSubmitting = true
        
        let autoSummitHandler = {(image:NSImage)->() in
            if self.ifShowCode {
                self.switchViewFrom(self.orderInfoView, to: self.preOrderView)
                if AdvancedPreferenceManager.sharedInstance.isUseDama {
                    self.dama(image: image)
                }
                self.isSubmitting = false
            }
            else {
                self.submitOrderFlow(isAuto: true,ifShowRandCode: false)
            }
        }
        let successHandler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            if self.isAutoSubmit {
                autoSummitHandler(image)
            }
            else {
                self.isSubmitting = false
            }
            self.stopLoadingTip()
        }
        
        let failureHandler = { (error:NSError) -> () in
            self.showTip(translate(error))
            self.isSubmitting = false
            self.stopLoadingTip()
        }
        
        Service.sharedInstance.preOrderFlow(isAuto: self.isAutoSubmit,success: successHandler, failure: failureHandler)
    }
    
    func checkOrderFlow()  {
        self.startLoadingTip("验证订单...")
        
        let failureHandler = { (error:NSError) -> () in
            self.stopLoadingTip()
            self.isSubmitting = false
            self.showTip(translate(error))
        }
        
        let successHandler = {(ifShowRandCode:Bool)->() in
            if ifShowRandCode {
                self.stopLoadingTip()
                self.isSubmitting = false
                self.switchViewFrom(self.orderInfoView, to: self.preOrderView)
            }
            else {
                self.submitOrderFlow(isAuto: false,ifShowRandCode: false)
            }
        }
        Service.sharedInstance.checkOrderFlow(success: successHandler, failure: failureHandler)
    }
    
    func closeAndReSubmit() {
        self.dismissWithModalResponse(NSModalResponseCancel)
        NotificationCenter.default.post(name: Notification.Name.App.DidStartQueryTicket, object:nil)
    }
    
    func submitOrderFlow(isAuto:Bool = false,ifShowRandCode:Bool = false,randCode:String = ""){
        if isAuto {
            self.startLoadingTip("正在自动提交...")
        }
        else {
            self.startLoadingTip("正在提交...")
        }
        
        let failureHandler = { (error:NSError) -> () in
            self.stopLoadingTip()
            if ServiceError.isCheckRandCodeError(error) {
                self.showTip(translate(error))
                self.freshImage()
                //if isAuto and use Dama, then should try to use Dama
            }
            else {
                //if isAuto and not CheckRandCodeError, then close window and retry
                if isAuto {
                    self.showTip(translate(error) + " 请等待3秒App会自动重新提交")
                    
                    if !self.isCancel {
                        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(SubmitWindowController.closeAndReSubmit), userInfo: nil, repeats: false)
                    }
                    else {
                        logger.info("取消自动重新提交车次 \(self.trainCodeLabel.stringValue)")
                    }
                }
                else {
                    self.showTip(translate(error) + " 可尝试重新查询车票并提交！")
                }
            }
            
            self.isSubmitting = false
        }
        
        let successHandler = {
            self.stopLoadingTip()
            self.orderId.stringValue = MainModel.orderId!
            if ifShowRandCode {
                self.switchViewFrom(self.preOrderView, to: self.orderIdView)
            }
            else {
                self.switchViewFrom(self.orderInfoView, to: self.orderIdView)
            }
            self.isSubmitting = false
        }
        
        let waitHandler = { (info:String)-> () in
            self.startLoadingTip(info)
        }
        
        if isAuto {
            if ifShowRandCode {
                Service.sharedInstance.autoOrderFlowWithRandCode(randCode, success: successHandler, failure: failureHandler,wait: waitHandler)
            }
            else {
                Service.sharedInstance.autoOrderFlowNoRandCode(success: successHandler, failure: failureHandler,wait: waitHandler)
            }
        }
        else {
            if ifShowRandCode {
                Service.sharedInstance.orderFlowWithRandCode(randCode, success: successHandler, failure: failureHandler,wait: waitHandler)
            }
            else {
                Service.sharedInstance.orderFlowNoRandCode(success: successHandler, failure: failureHandler,wait: waitHandler)
            }
        }
    }
    
// MARK: - click Action
    @IBAction func clickNext(_ sender: AnyObject?) {
        if self.window!.contentView!.subviews.contains(orderInfoView) {
            self.clickCheckOrder(nil)
        }
        else if self.window!.contentView!.subviews.contains(preOrderView) {
            self.clickOK(nil)
        }
        else {
            self.clickRateInAppstore(nil)
        }
    }
    
    @IBAction func clickNextImage(_ sender: NSButton) {
        freshImage()
    }
    
    @IBAction func clickCheckOrder(_ sender: AnyObject?) {
        if isSubmitting {
            return
        }
        isSubmitting = true
        
        if isAutoSubmit {
            self.submitOrderFlow(isAuto: true,ifShowRandCode: false)
        }
        else {
            self.checkOrderFlow()
        }
    }
    
    @IBAction func clickOK(_ sender:AnyObject?){
        if let randCode = passengerImage.randCodeStr {
            if isSubmitting {
                return
            }
            
            isSubmitting = true
            
            self.submitOrderFlow(isAuto: isAutoSubmit,ifShowRandCode: true, randCode: randCode)
        }
        else {
            self.showTip("请先选择验证码")
        }
    }
    
    @IBAction func clickCancel(_ button:NSButton){
        if timer != nil {
            timer!.invalidate()
        }
        isCancel = true
        
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    @IBAction func clickExcludeTrain(_ button:NSButton) {
        isCancel = true
        NotificationCenter.default.post(name: Notification.Name.App.DidExcludeTrainSubmit, object:MainModel.selectedTicket!.TrainCode)
        closeAndReSubmit()
    }
    
    @IBAction func clickRateInAppstore(_ button:AnyObject?){
        NSWorkspace.shared().open(URL(string: "macappstore://itunes.apple.com/us/app/ding-piao-zhu-shou/id1163682213?l=zh&ls=1&mt=12")!)
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    deinit {
        print("SubmitWindowController deinit")
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
