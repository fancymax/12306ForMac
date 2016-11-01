//
//  URLButton.swift
//  12306ForMac
//
//  Created by fancymax on 16/7/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class URLButton: NSButton {

    fileprivate var hovered: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    func commonInit(){
//        self.wantsLayer = true
        self.createTrackingArea()
        self.hovered = false
    }
    
    fileprivate var trackingArea: NSTrackingArea!
    func createTrackingArea(){
        if(self.trackingArea != nil){
            self.removeTrackingArea(self.trackingArea!)
        }
        let circleRect = self.bounds
        let flag = NSTrackingAreaOptions.mouseEnteredAndExited.rawValue + NSTrackingAreaOptions.activeInActiveApp.rawValue
        self.trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        self.hovered = true
        self.needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        self.addCursorRect(self.bounds, cursor: NSCursor.pointingHand())
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if (hovered){
            let bottomLine = NSBezierPath()
            bottomLine.move(to: NSMakePoint(NSMinX(bounds), NSMaxY(bounds)))
            bottomLine.line(to: NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)))
            bottomLine.lineWidth = 2.0
            bottomLine.stroke()
        }
    }
    
}
