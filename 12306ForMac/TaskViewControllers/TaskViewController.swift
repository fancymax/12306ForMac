//
//  TaskViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/13.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TaskViewController: NSViewController {
    var stationDataService = StationData()

    @IBOutlet weak var fromStationName: AutoCompleteTextField!
    @IBOutlet weak var toStationName: AutoCompleteTextField!
    
    @IBOutlet weak var taskListTable: NSTableView!
    var tasks = [TicketTask]()
    
    @IBAction func addTask(sender: NSButton) {
        let task = TicketTask()
        tasks.append(task)
        
        taskListTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromStationName.tableViewDelegate = self
        self.toStationName.tableViewDelegate = self
    }
}

extension TaskViewController:NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tasks.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return tasks[row]
    }
}

// MARK: - AutoCompleteTableViewDelegate
extension TaskViewController: AutoCompleteTableViewDelegate{
    func textField(textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        var matches = [String]()
        //先按简拼  再按全拼  并保留上一次的match
        for station in stationDataService.allStation
        {
            if let _ = station.FirstLetter.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
            {
                matches.append(station.Name)
            }
        }
        
        if(matches.isEmpty)
        {
            for station in stationDataService.allStation
            {
                if let _ = station.Spell.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
                {
                    matches.append(station.Name)
                }
            }
        }
        //再按汉字
        if(matches.isEmpty)
        {
            for station in stationDataService.allStation
            {
                if let _ = station.Name.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
                {
                    matches.append(station.Name)
                }
            }
        }
        
        return matches
    }
}
