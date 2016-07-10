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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }
    
    func setCenterConstrainBy(view otherView: NSView) {
        let constraint1 = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: otherView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        let constraint2 = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: otherView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activateConstraints([constraint1,constraint2])
    }
    
    func start(tip tip:String)
    {
        loadingSpinner.startAnimation(nil)
        loadingTip.stringValue = tip
        loadingView.hidden = false
    }
    
    func stop(){
        loadingSpinner.stopAnimation(nil)
        loadingView.hidden = true
    }
    
    func setTipView(isHidden hidden: Bool) {
        loadingView.hidden = hidden
    }
}
