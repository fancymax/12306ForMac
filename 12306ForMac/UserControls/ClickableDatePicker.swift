//
//  ClickableDatePicker.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/2.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class ClickableDatePicker: NSDatePicker {

    override func mouseDown(theEvent: NSEvent) {
        if self.enabled {
            sendAction(self.action, to: self.target)
        }
    }
    
}
