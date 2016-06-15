//
//  ContentBackgroundView.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class ContentBackgroundView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        Theme.GobalTheme.backgroundColor.set()
        NSRectFill(dirtyRect)
    }
    
}
