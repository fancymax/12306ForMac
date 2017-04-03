//
//  filterPreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 2017/4/2.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Cocoa
import MASPreferences

class FilterTimeSpan:NSObject {
    var start:String = ""
    var end:String = ""
    var isCheck = true
    
    override var debugDescription: String {
        return "\(start)~\(end) \(isCheck)"
    }
}

class FilterPreferenceViewController: NSViewController {
    
    override var nibName: String? {
        return "FilterPreferenceViewController"
    }
    
    override var identifier: String!{
        get {
            return "FilterPreferences"
        }
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: "DefineFilter")
    }
    
    var toolbarItemLabel: String! {
        return NSLocalizedString("筛选", comment: "Filter")
    }
    
    @IBOutlet weak var startFilterTimeSpanTable: NSTableView!
    @IBOutlet weak var startTimeSpanComboBox: NSComboBox!
    
    @IBOutlet weak var endFilterTimeSpanTable: NSTableView!
    @IBOutlet weak var endTimeSpanComboBox: NSComboBox!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initStartFilterTimeSpans()
        self.initEndFilterTimeSpans()
    }
    
    var startFilterTimeSpans:[FilterTimeSpan] = [FilterTimeSpan]()
    private func initStartFilterTimeSpans() {
        var timeSpan = GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeSpan
        var timeStatus = GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeStatus
        
        startFilterTimeSpans = [FilterTimeSpan]()
        
        let count = min(timeSpan.count, timeStatus.count)
        
        for i in 0..<count {
            let filterTime = FilterTimeSpan()
            filterTime.start = timeSpan[i].components(separatedBy: "~")[0]
            filterTime.end = timeSpan[i].components(separatedBy: "~")[1]
            filterTime.isCheck = timeStatus[i]
            startFilterTimeSpans.append(filterTime)
        }
        
        startTimeSpanComboBox.selectItem(at: startFilterTimeSpans.count - 3)
        startFilterTimeSpanTable.reloadData()
    }
    
    var endFilterTimeSpans:[FilterTimeSpan] = [FilterTimeSpan]()
    private func initEndFilterTimeSpans() {
        var timeSpan = GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeSpan
        var timeStatus = GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeStatus
        
        endFilterTimeSpans = [FilterTimeSpan]()
        
        let count = min(timeSpan.count, timeStatus.count)
        
        for i in 0..<count {
            let filterTime = FilterTimeSpan()
            filterTime.start = timeSpan[i].components(separatedBy: "~")[0]
            filterTime.end = timeSpan[i].components(separatedBy: "~")[1]
            filterTime.isCheck = timeStatus[i]
            endFilterTimeSpans.append(filterTime)
        }
        
        endTimeSpanComboBox.selectItem(at: endFilterTimeSpans.count - 3)
        endFilterTimeSpanTable.reloadData()
    }
    
    @IBAction func clickStartTimSpanComboBox(_ sender: NSComboBox) {
        var timeSpan = [String]()
        var timeStatus = [true,true,true]
        if sender.indexOfSelectedItem == 0 {
            timeSpan = ["00:00~09:00","09:00~17:00","17:00~24:00"]
        }
        else if sender.indexOfSelectedItem == 1 {
            timeSpan = ["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"]
            timeStatus.append(true)
        }
        else {
            timeSpan = ["00:00~06:00","06:00~09:00","09:00~17:00","17:00~19:00","19:00~24:00"]
            timeStatus.append(true)
            timeStatus.append(true)
        }
        GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeSpan = timeSpan
        GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeStatus = timeStatus
        initStartFilterTimeSpans()
    }
    
    @IBAction func clickEndTimSpanComboBox(_ sender: NSComboBox) {
        var timeSpan = [String]()
        var timeStatus = [true,true,true]
        if sender.indexOfSelectedItem == 0 {
            timeSpan = ["00:00~09:00","09:00~17:00","17:00~24:00"]
        }
        else if sender.indexOfSelectedItem == 1 {
            timeSpan = ["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"]
            timeStatus.append(true)
        }
        else {
            timeSpan = ["00:00~06:00","06:00~09:00","09:00~17:00","17:00~19:00","19:00~24:00"]
            timeStatus.append(true)
            timeStatus.append(true)
        }
        GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeSpan = timeSpan
        GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeStatus = timeStatus
        initEndFilterTimeSpans()
    }
    
    override func viewDidDisappear() {
        var newTimeSpanStrList = [String]()
        var newTimeStatus = [Bool]()
        for time in startFilterTimeSpans {
            newTimeSpanStrList.append("\(time.start)~\(time.end)")
            newTimeStatus.append(time.isCheck)
        }
        GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeSpan = newTimeSpanStrList
        GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeStatus = newTimeStatus
        
        newTimeSpanStrList.removeAll()
        newTimeStatus.removeAll()
        for time in endFilterTimeSpans {
            newTimeSpanStrList.append("\(time.start)~\(time.end)")
            newTimeStatus.append(time.isCheck)
        }
        GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeSpan = newTimeSpanStrList
        GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeStatus = newTimeStatus
        
        NotificationCenter.default.post(name: Notification.Name.App.DidTrainFilterKeyChange, object:nil)
    }
    
}

extension FilterPreferenceViewController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == startFilterTimeSpanTable {
            return startFilterTimeSpans.count
        }
        else {
            return endFilterTimeSpans.count
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == startFilterTimeSpanTable {
            return startFilterTimeSpans[row]
        }
        else {
            return endFilterTimeSpans[row]
        }
    }
}
