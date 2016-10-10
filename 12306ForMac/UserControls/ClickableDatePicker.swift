//
//  ClickableDatePicker.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/2.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class ClickableDatePicker: NSDatePicker {
    
    @IBInspectable var clickable:Bool = true

    override func mouseDown(with theEvent: NSEvent) {
        if self.clickable {
            sendAction(self.action, to: self.target)
        }
    }
    
}
