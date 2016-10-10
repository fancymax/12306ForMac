//
//  ContentBackgroundView.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class ContentBackgroundView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        Theme.GobalTheme.backgroundColor.set()
        NSRectFill(dirtyRect)
    }
    
}
