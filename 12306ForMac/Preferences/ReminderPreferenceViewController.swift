//
//  ReminderPreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 2017/3/10.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Cocoa
import MASPreferences

class ReminderPreferenceViewController: NSViewController,MASPreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var nibName: String? {
        return "ReminderPreferenceViewController"
    }
    
    override var identifier: String!{
        get {
            return "ReminderPreference"
        }
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: "Reminder.png")
    }
    
    var toolbarItemLabel: String! {
        return NSLocalizedString("提醒", comment: "Reminder")
    }
    
}
