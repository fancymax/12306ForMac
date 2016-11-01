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
        self.backgroundColor?.set()
        NSRectFill(dirtyRect)
        NSGraphicsContext.restoreGraphicsState()
    }
    
}


