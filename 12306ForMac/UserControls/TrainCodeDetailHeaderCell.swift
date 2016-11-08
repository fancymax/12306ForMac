//
//  TrainCodeDetailHeaderCell.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainCodeDetailHeaderCell: NSTableHeaderCell {

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        let (borderRect, fillRect) = cellFrame.divided(atDistance: 1.0, from: .maxYEdge)
        
        //header bottom line
        NSColor(calibratedRed: 0.850887, green: 0.851034, blue: 0.850878, alpha: 1.0).set()
        NSRectFill(borderRect)
        
        Theme.GobalTheme.backgroundColor.set()
        NSRectFill(fillRect)
        self.drawInterior(withFrame: fillRect.insetBy(dx: 0.0, dy: 1.0), in: controlView)
    }
    
}
