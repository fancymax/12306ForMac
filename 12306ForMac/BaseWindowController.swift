//
//  BaseWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 2016/12/1.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class BaseWindowController: NSWindowController {

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
    
    func dismissWithModalResponse(_ response:NSModalResponse)
    {
        if window != nil {
            if window!.sheetParent != nil {
                window!.sheetParent!.endSheet(window!,returnCode: response)
            }
        }
    }
}

class BaseViewController: NSViewController{
    func showTip(_ tip:String){
        DJTipHUD.showStatus(tip, from: self.view)
    }
    
    func startLoadingTip(_ tip:String)
    {
        DJLayerView.showStatus(tip, from: self.view)
    }
    
    func stopLoadingTip(){
        DJLayerView.dismiss()
    }
}
