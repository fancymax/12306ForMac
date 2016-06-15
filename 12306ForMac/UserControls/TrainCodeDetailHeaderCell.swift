//
//  TrainCodeDetailHeaderCell.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/15.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainCodeDetailHeaderCell: NSTableHeaderCell {

    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        let (borderRect, fillRect) = cellFrame.divide(1.0, fromEdge: .MaxYEdge)
        
        //header bottom line
        NSColor.grayColor().set()
        NSRectFill(borderRect)
        
        NSColor(calibratedRed:0.921569, green:0.921569, blue:0.921569, alpha:1.0).set()
        NSRectFill(fillRect)
        self.drawInteriorWithFrame(CGRectInset(fillRect, 0.0, 1.0), inView: controlView)
    }
    
}
