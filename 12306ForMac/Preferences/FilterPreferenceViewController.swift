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
    
    override var debugDescription: String {
        return "\(start)~\(end)"
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
        var timeSpanStrArr = GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeSpan
        if timeSpanStrArr.count == 0 {
            timeSpanStrArr = ["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"]
        }
        startFilterTimeSpans = [FilterTimeSpan]()
        for timespan in timeSpanStrArr {
            let filterTime = FilterTimeSpan()
            filterTime.start = timespan.components(separatedBy: "~")[0]
            filterTime.end = timespan.components(separatedBy: "~")[1]
            startFilterTimeSpans.append(filterTime)
        }
        startTimeSpanComboBox.selectItem(at: startFilterTimeSpans.count - 3)
        startFilterTimeSpanTable.reloadData()
    }
    
    var endFilterTimeSpans:[FilterTimeSpan] = [FilterTimeSpan]()
    private func initEndFilterTimeSpans() {
        var timeSpanStrArr = GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeSpan
        if timeSpanStrArr.count == 0 {
            timeSpanStrArr = ["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"]
        }
        endFilterTimeSpans = [FilterTimeSpan]()
        for timespan in timeSpanStrArr {
            let filterTime = FilterTimeSpan()
            filterTime.start = timespan.components(separatedBy: "~")[0]
            filterTime.end = timespan.components(separatedBy: "~")[1]
            endFilterTimeSpans.append(filterTime)
        }
        endTimeSpanComboBox.selectItem(at: endFilterTimeSpans.count - 3)
        endFilterTimeSpanTable.reloadData()
    }
    
    @IBAction func clickStartTimSpanComboBox(_ sender: NSComboBox) {
        var timeSpan = [String]()
        if sender.indexOfSelectedItem == 0 {
            timeSpan = ["00:00~09:00","09:00~17:00","17:00~24:00"]
        }
        else if sender.indexOfSelectedItem == 1 {
            timeSpan = ["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"]
        }
        else {
            timeSpan = ["00:00~06:00","06:00~09:00","09:00~17:00","17:00~19:00","19:00~24:00"]
        }
        GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeSpan = timeSpan
        initStartFilterTimeSpans()
    }
    
    @IBAction func clickEndTimSpanComboBox(_ sender: NSComboBox) {
        var timeSpan = [String]()
        if sender.indexOfSelectedItem == 0 {
            timeSpan = ["00:00~09:00","09:00~17:00","17:00~24:00"]
        }
        else if sender.indexOfSelectedItem == 1 {
            timeSpan = ["00:00~06:00","06:00~12:00","12:00~18:00","18:00~24:00"]
        }
        else {
            timeSpan = ["00:00~06:00","06:00~09:00","09:00~17:00","17:00~19:00","19:00~24:00"]
        }
        GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeSpan = timeSpan
        initEndFilterTimeSpans()
    }
    
    override func viewDidDisappear() {
        var newTimeSpanStrList = [String]()
        for time in startFilterTimeSpans {
            newTimeSpanStrList.append("\(time.start)~\(time.end)")
        }
        GeneralPreferenceManager.sharedInstance.userDefindStartFilterTimeSpan = newTimeSpanStrList
        
        newTimeSpanStrList.removeAll()
        for time in endFilterTimeSpans {
            newTimeSpanStrList.append("\(time.start)~\(time.end)")
        }
        GeneralPreferenceManager.sharedInstance.userDefindEndFilterTimeSpan = newTimeSpanStrList
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
