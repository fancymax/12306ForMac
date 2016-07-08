//
//  FlashLabel.swift
//  FlashLabel
//
//  Created by Kauntey Suryawanshi on 07/07/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

public class FlashLabel: NSTextField {
    
    private var timer: NSTimer!
    private var timeSummation = CGFloat(0)
    let flashInterval = NSTimeInterval(0.5)
    var showTime: CGFloat!
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer!.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        self.setVisibility(false, animated: false)
    }

    var showAnimation: CABasicAnimation = {
        var showAnimation = CABasicAnimation()
        showAnimation = CABasicAnimation(keyPath: "opacity")
        showAnimation.duration = 3
        showAnimation.fromValue = 0
        showAnimation.toValue = 1
        showAnimation.repeatCount = 0
        return showAnimation
    }()

    var hideAnimation: CABasicAnimation = {
        var showAnimation = CABasicAnimation()
        showAnimation = CABasicAnimation(keyPath: "opacity")
        showAnimation.duration = 3
        showAnimation.fromValue = 1
        showAnimation.toValue = 0
        showAnimation.repeatCount = 0
        return showAnimation
        }()

    /**
    Shows the FlashLabel for specified time
    
    - parameter text: Stringvalue of the label
    - parameter time: Time to live in seconds
    - parameter flash: enabled will flash/blink the label
    
    */
    public func show(text: String, forDuration time: CGFloat, withFlash flash: Bool) {
        self.setVisibility(true, animated: false)
        self.stringValue = text
        self.sizeToFit()
        if flash {
            timeSummation = 0
            showTime = time
            timer = NSTimer.scheduledTimerWithTimeInterval(flashInterval, target: self, selector: #selector(FlashLabel.flashNotify), userInfo: nil, repeats: true)
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(time), target: self, selector: #selector(FlashLabel.timerNotify), userInfo: nil, repeats: false)
        }
    }
    
    func timerNotify() {
        self.setVisibility(false, animated: true)
    }

    private var visible = false
    func flashNotify() {
        if timeSummation < showTime {
            timeSummation += 0.5
            self.setVisibility(visible, animated: false)
            visible = !visible
        } else {
            timer.invalidate()
            self.setVisibility(false, animated: false)
        }
    }

    func setVisibility(enabled: Bool, animated: Bool) {
        if animated {
            if enabled {
                self.layer!.addAnimation(showAnimation, forKey: nil)
            } else {
                self.layer!.addAnimation(hideAnimation, forKey: nil)
            }
        }
        self.layer!.opacity  = enabled ? 1 : 0
    }
}
