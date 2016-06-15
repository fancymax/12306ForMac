//
//  Theme.swift
//  WWDC
//
//  Created by Guilherme Rambo on 18/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

import Cocoa

private let _SharedThemeInstance = Theme()

class Theme: NSObject {

    class var GobalTheme: Theme {
        return _SharedThemeInstance
    }
    
    let backgroundColor = NSColor(calibratedRed:0.921569, green:0.921569, blue:0.921569, alpha:1.0)
}