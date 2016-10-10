//
//  ItemCellView.swift
//  Train12306
//
//  Created by fancymax on 16/2/2.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class ItemCellView:NSTableCellView{
    
    override var backgroundStyle: NSBackgroundStyle{
        set{
            var textColor:NSColor?
            if newValue == NSBackgroundStyle.dark{
                textColor = NSColor.windowBackgroundColor
            }
            else{
                textColor = NSColor.controlShadowColor
            }
            let mark = self.viewWithTag(11) as! NSTextField
            mark.textColor = textColor
            super.backgroundStyle = newValue
        }
        get{
            return super.backgroundStyle
        }

    }
    
    
}
