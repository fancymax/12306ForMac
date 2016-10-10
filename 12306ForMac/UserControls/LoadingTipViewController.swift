//
//  LoadingTipViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/7/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class LoadingTipViewController: NSViewController {
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingTip: NSTextField!
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    override var nibName: String?{
        return "LoadingTipViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }
    
    func setCenterConstrainBy(view otherView: NSView) {
        let constraint1 = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: otherView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        let constraint2 = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: otherView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([constraint1,constraint2])
    }
    
    func start(tip:String)
    {
        loadingSpinner.startAnimation(nil)
        loadingTip.stringValue = tip
        loadingView.isHidden = false
    }
    
    func stop(){
        loadingSpinner.stopAnimation(nil)
        loadingView.isHidden = true
    }
    
    func setTipView(isHidden hidden: Bool) {
        loadingView.isHidden = hidden
    }
}
