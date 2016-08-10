//
//  AdvancePreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class AdvancedPreferenceViewController: NSViewController,MASPreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
// MARK: - MASPreferencesViewController
    override var identifier: String!{
        get {
            return "AdvancedPreferences"
        }
        set{}
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: NSImageNameAdvanced)
    }
    
    var toolbarItemLabel: String! {
        return NSLocalizedString("打码兔", comment: "")
    }
    
// MARK: - UserDefault
    var isUseDama:Bool {
        get {
            return AdvancedPreferenceManager.sharedInstance.isUseDama
        }
        set {
            AdvancedPreferenceManager.sharedInstance.isUseDama = newValue
        }
    }
    
    var isUseDamaLogin:Bool {
        get{
            return AdvancedPreferenceManager.sharedInstance.isUseDamaLogin
        }
        set{
            AdvancedPreferenceManager.sharedInstance.isUseDamaLogin = newValue
        }
    }
    
    var isStopDamaWhenOperate:Bool {
        get{
            return AdvancedPreferenceManager.sharedInstance.isStopDamaWhenOperate
        }
        set{
            AdvancedPreferenceManager.sharedInstance.isStopDamaWhenOperate = newValue
        }
    }
    
    var isStopDamaWhenFail5:Bool {
        get{
            return AdvancedPreferenceManager.sharedInstance.isStopDamaWhenFail5
        }
        set{
            AdvancedPreferenceManager.sharedInstance.isStopDamaWhenFail5 = newValue
            
        }
    }
    
    var damaUser:String {
        get{
            return AdvancedPreferenceManager.sharedInstance.damaUser
        }
        set{
            AdvancedPreferenceManager.sharedInstance.damaUser = newValue
        }
    }
    
    var damaPassword:String{
        get{
            return AdvancedPreferenceManager.sharedInstance.damaPassword
        }
        set{
            AdvancedPreferenceManager.sharedInstance.damaPassword = newValue
        }
    }
}
