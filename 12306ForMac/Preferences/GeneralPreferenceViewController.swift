//
//  GeneralPreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class GeneralPreferenceViewController: NSViewController, MASPreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var identifier: String!{
        get {
            return "GeneralPreferences"
        }
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: NSImageNamePreferencesGeneral)
    }

    var toolbarItemLabel: String! {
        return NSLocalizedString("通用", comment: "General")
    }
    
}
