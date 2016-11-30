//
//  PayWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 2016/11/30.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa
import WebKit

class PayWindowController: NSWindowController,NSWindowDelegate {

    @IBOutlet weak var payWeb: WebView!
    var request:URLRequest?
    override var windowNibName: String{
        return "PayWindowController"
    }
    override func windowDidLoad() {
        super.windowDidLoad()

        payWeb.mainFrame.load(request)
        print("windowDidLoad")
    }
    
    func runModalby(parentWnd:NSWindow,withRequest request:URLRequest)->Int {
        self.request = request
        return NSApp.runModal(for: window!)
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.abortModal()
        self.window?.orderOut(nil)
        return true
    }
    
}
