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
    @IBOutlet weak var remindAccessLabel: NSTextField!
    @IBOutlet weak var remindAccessInfoButton: InfoButton!
    
    var hasAccessGrantedReminder = false {
        didSet {
            if hasAccessGrantedReminder {
                remindAccessLabel.stringValue = "提醒权限☑"
                remindAccessInfoButton.isHidden = true
            }
            else {
                remindAccessLabel.stringValue = "提醒权限☒"
                remindAccessInfoButton.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        if ReminderManager.sharedInstance.updateAuthorizationStatus() {
            hasAccessGrantedReminder = true
        }
        else {
            hasAccessGrantedReminder = false
        }
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
