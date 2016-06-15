//
//  LoginButton.swift
//  HoverButtonDemo
//
//  Created by fancymax on 16/1/29.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class LoginButton: NSButton{
    private var hovered: Bool = false
    
    var textColor: NSColor? {
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
        self.wantsLayer = true
        self.createTrackingArea()
        self.hovered = false
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
    
    override func mouseEntered(theEvent: NSEvent) {
        self.hovered = true
        self.needsDisplay = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
    }
    
    func drawText(text:String, inRect:NSRect){
        let aParagraghStyle = NSMutableParagraphStyle()
        aParagraghStyle.lineBreakMode  = NSLineBreakMode.ByWordWrapping
        aParagraghStyle.alignment  = NSTextAlignment.Left
        
        if nil == self.textColor {
            self.textColor = NSColor.blackColor()
        }
        let attrs = [NSParagraphStyleAttributeName:aParagraghStyle, NSFontAttributeName:self.font!, NSForegroundColorAttributeName:self.textColor!]
        let size = (text as NSString).sizeWithAttributes(attrs)
        let r:NSRect = NSMakeRect(inRect.origin.x,
            inRect.origin.y + (inRect.size.height - size.height)/2.0 - 2,
            inRect.size.width,
            size.height)
        (text as NSString).drawInRect(r, withAttributes: attrs)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        
        var imageRect = NSRect()
        if let image = self.image{
            imageRect.size.height = self.bounds.height - 6
            imageRect.size.width  = imageRect.size.height
            imageRect.origin.x = 3
            imageRect.origin.y = 3
            image.drawInRect(imageRect)
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
            NSColor.lightGrayColor().set()
            bgPath.lineWidth = 1
            bgPath.stroke()
        }
        
        drawText(self.title, inRect: textRect)
        
        NSGraphicsContext.restoreGraphicsState()
    }
}
