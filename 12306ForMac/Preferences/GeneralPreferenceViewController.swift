//
//  GeneralPreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa
import MASPreferences

class FilterTimeSpan:NSObject {
    var start:String = ""
    var end:String = ""
    
    override var debugDescription: String {
        return "\(start)~\(end)"
    }
}

class GeneralPreferenceViewController: NSViewController, MASPreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFilterTimeSpans()
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
    
    @IBOutlet weak var filterTimeSpanTable: NSTableView!
    
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
                willChangeValue(forKey: "isShowInvalidTicket")
                isShowInvalidTicket = false
                didChangeValue(forKey: "isShowInvalidTicket")
            }
            else {
                NotificationCenter.default.post(name: Notification.Name.App.DidRefilterQueryTicket, object:nil)
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
                willChangeValue(forKey: "isShowNoTrainTicket")
                isShowNoTrainTicket = true
                didChangeValue(forKey: "isShowNoTrainTicket")
            }
            else {
                NotificationCenter.default.post(name: Notification.Name.App.DidRefilterQueryTicket, object:nil)
            }
        }
    }
    
    var isAutoQueryAfterFilter: Bool {
        get{
            return GeneralPreferenceManager.sharedInstance.isAutoQueryAfterFilter
        }
        set{
            GeneralPreferenceManager.sharedInstance.isAutoQueryAfterFilter = newValue
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
    
    var isNotifyLogin: Bool {
        get{
            return GeneralPreferenceManager.sharedInstance.isNotifyLogin
        }
        set{
            GeneralPreferenceManager.sharedInstance.isNotifyLogin = newValue
            NotifySpeaker.sharedInstance.notifyLogin()
        }
    }
    
    var notifyLoginStr: String {
        get{
            return GeneralPreferenceManager.sharedInstance.notifyLoginStr
        }
        set{
            GeneralPreferenceManager.sharedInstance.notifyLoginStr = newValue
        }
    }
    
    var filterTimeSpans:[FilterTimeSpan] = [FilterTimeSpan]()
    private func initFilterTimeSpans() {
        let timeSpanStrArr = GeneralPreferenceManager.sharedInstance.userDefindFilterTimeSpan
        for timespan in timeSpanStrArr {
            let filterTime = FilterTimeSpan()
            filterTime.start = timespan.components(separatedBy: "~")[0]
            filterTime.end = timespan.components(separatedBy: "~")[1]
            filterTimeSpans.append(filterTime)
        }
    }
    
    override func viewDidDisappear() {
        print(filterTimeSpans)
    }
}

extension GeneralPreferenceViewController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filterTimeSpans.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return filterTimeSpans[row]
    }
}
