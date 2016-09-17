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
    
    override var nibName: String? {
        return "GeneralPreferenceViewController"
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
    
    var autoQuerySeconds: Int {
        get{
            return GeneralPreferenceManager.sharedInstance.autoQuerySeconds
        }
        set{
            GeneralPreferenceManager.sharedInstance.autoQuerySeconds = newValue
        }
    }
    
    var isShowNoTrainTicket: Bool {
        get{
            return GeneralPreferenceManager.sharedInstance.isShowNoTrainTicket
        }
        set{
            GeneralPreferenceManager.sharedInstance.isShowNoTrainTicket = newValue
            if !newValue {
                willChangeValueForKey("isShowInvalidTicket")
                isShowInvalidTicket = false
                didChangeValueForKey("isShowInvalidTicket")
            }
        }
    }
    
    var isShowInvalidTicket: Bool {
        get{
            return GeneralPreferenceManager.sharedInstance.isShowInvalidTicket
        }
        set{
            GeneralPreferenceManager.sharedInstance.isShowInvalidTicket = newValue
            if newValue {
                willChangeValueForKey("isShowNoTrainTicket")
                isShowNoTrainTicket = true
                didChangeValueForKey("isShowNoTrainTicket")
            }
        }
    }
    
    var isNotifyTicket: Bool {
        get{
            return GeneralPreferenceManager.sharedInstance.isNotifyTicket
        }
        set{
            GeneralPreferenceManager.sharedInstance.isNotifyTicket = newValue
            NotifySpeaker.sharedInstance.notify()
        }
    }
    
    var notifyStr: String {
        get{
            return GeneralPreferenceManager.sharedInstance.notifyStr
        }
        set{
            GeneralPreferenceManager.sharedInstance.notifyStr = newValue
        }
    }
    
}
