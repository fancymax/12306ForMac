//
//  PayWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 2016/11/30.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa
import WebKit

class PayWindowController: NSWindowController {

    var request:URLRequest?
    @IBOutlet weak var payWeb: WebView!
    override var windowNibName: String{
        return "PayWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        refreshPay()
    }
    
    func dismissWithModalResponse(_ response:NSModalResponse)
    {
        if window != nil {
            if window!.sheetParent != nil {
                window!.sheetParent!.endSheet(window!,returnCode: response)
            }
        }
    }
    
    func refreshPay()  {
        let successHandler = {(request:URLRequest) in
            self.payWeb.mainFrame.load(request)
            self.stopLoadingTip()
        }
        
        let failureHandler = {(error:NSError) -> () in
            self.stopLoadingTip()
            self.showTip(translate(error))
        }
        
        self.startLoadingTip("正在加载...")
        
        Service.sharedInstance.payFlow(success: successHandler, failure: failureHandler)
    }
    
    func showTip(_ tip:String)  {
        DJTipHUD.showStatus(tip, from: self.window?.contentView)
    }
    
    func startLoadingTip(_ tip:String)
    {
        DJLayerView.showStatus(tip, from: self.window?.contentView)
    }
    
    func stopLoadingTip(){
        DJLayerView.dismiss()
    }
    
    @IBAction func clickRefreshPay(_ button:NSButton) {
        self.refreshPay()
    }
    
    @IBAction func clickCancel(_ button:NSButton){
        dismissWithModalResponse(NSModalResponseOK)
    }
    
    @IBAction func open12306(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://kyfw.12306.cn/otn/login/init")!)
    }
    
}
