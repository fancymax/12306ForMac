//
//  GlassView.swift
//  Train12306
//
//  Created by fancymax on 16/1/28.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class GlassView: NSView{
    var backgroundColor:NSColor?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    func commonInit(){
        self.backgroundColor = NSColor.clear

    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        let bounds = self.bounds
        var upperBounds = bounds
        
        upperBounds.size.height -= 10
        upperBounds.origin.y += 10
        
        let borderPath = NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5)
        borderPath.appendRect(upperBounds)
        self.backgroundColor?.set()
        borderPath.fill()
        NSGraphicsContext.restoreGraphicsState()
    }
    
}


