//
//  LoginButton.swift
//  HoverButtonDemo
//
//  Created by fancymax on 16/1/29.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class LoginButton: NSButton{
    var hovered: Bool = false
    
    var textColor: NSColor = NSColor.black
    
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
        if !self.isEnabled {
            return
        }
        
        self.hovered = true
        self.needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
    }
    
    func drawText(_ text:String, inRect:NSRect){
        let aParagraghStyle = NSMutableParagraphStyle()
        aParagraghStyle.lineBreakMode  = NSLineBreakMode.byWordWrapping
        aParagraghStyle.alignment  = NSTextAlignment.left
        
        let attrs = [NSParagraphStyleAttributeName:aParagraghStyle, NSFontAttributeName:self.font!, NSForegroundColorAttributeName:self.textColor] as [String : Any]
        let size = (text as NSString).size(withAttributes: attrs)
        let r:NSRect = NSMakeRect(inRect.origin.x,
            inRect.origin.y + (inRect.size.height - size.height)/2.0 - 2,
            inRect.size.width,
            size.height)
        (text as NSString).draw(in: r, withAttributes: attrs)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        
        var imageRect = NSRect()
        if let image = self.image{
            imageRect.size.height = self.bounds.height - 6
            imageRect.size.width  = imageRect.size.height
            imageRect.origin.x = 3
            imageRect.origin.y = 3
            image.draw(in: imageRect)
        }
        var textRect = self.bounds
        textRect.origin.x += imageRect.size.width + 10
        textRect.origin.y += 1
        textRect.size.width -= imageRect.size.width + 5
        
        if (hovered){
            var rect = self.bounds
            rect.size.height -= 2
            rect.size.width  -= 2
            rect.origin.x += 1
            rect.origin.y += 1
            let bgPath = NSBezierPath(roundedRect: rect, xRadius: 5, yRadius: 5)
            NSColor.lightGray.set()
            bgPath.lineWidth = 1
            bgPath.stroke()
        }
        
        drawText(self.title, inRect: textRect)
        
        NSGraphicsContext.restoreGraphicsState()
    }
}
