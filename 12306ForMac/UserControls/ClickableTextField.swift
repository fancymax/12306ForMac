//
//  ClickableTextField.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/11.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

@objc protocol ClickableTextFieldDelegate {
    func textFieldDidMouseEntered(sender: ClickableTextField)
    func textFieldDidMouseExited(sender: ClickableTextField)
}

class ClickableTextField: NSTextField {
    private var hovered: Bool = false
    weak var clickDelegate: ClickableTextFieldDelegate?
    
    var selected = false {
        didSet{
            self.needsDisplay = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    func commonInit(){
        self.createTrackingArea()
        self.hovered = false
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if hovered {
            let bottomLine = NSBezierPath()
            bottomLine.moveToPoint(NSMakePoint(NSMinX(bounds), NSMaxY(bounds)))
            bottomLine.lineToPoint(NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)))
            bottomLine.lineWidth = 2.0
            bottomLine.stroke()
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        Swift.print("mouse down")
    }

    override func mouseEntered(theEvent: NSEvent) {
        self.hovered = true
        self.needsDisplay = true
        if clickDelegate != nil {
            clickDelegate?.textFieldDidMouseEntered(self)
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
        if clickDelegate != nil {
            clickDelegate?.textFieldDidMouseExited(self)
        }
    }
    
    private var trackingArea: NSTrackingArea!
    func createTrackingArea(){
        if(self.trackingArea != nil){
            self.removeTrackingArea(self.trackingArea!)
        }
        let circleRect = self.bounds
        let flag = NSTrackingAreaOptions.MouseEnteredAndExited.rawValue + NSTrackingAreaOptions.ActiveInActiveApp.rawValue
        self.trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea)
    }
    
}
