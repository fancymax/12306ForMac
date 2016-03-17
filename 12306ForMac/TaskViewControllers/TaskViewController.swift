//
//  TaskViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/13.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa
import RealmSwift

class TaskViewController: NSViewController {
    var stationDataService = StationData()

    @IBOutlet weak var taskName: NSTextField!
    @IBOutlet weak var fromStationName: AutoCompleteTextField!
    @IBOutlet weak var toStationName: AutoCompleteTextField!
    
    @IBOutlet weak var taskListTable: NSTableView!
    var tasks = [TicketTask]()
    var currentTask: TicketTask = TicketTask()
    
    @IBAction func addTask(sender: NSButton) {
        let task = TicketTask()
        task.id = self.taskListTable.numberOfRows
        tasks.append(task)
        
        let index = taskListTable.numberOfRows
        self.taskListTable.reloadData()
        taskListTable.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
        loadTask(task)
        taskListTable.scrollRowToVisible(index)
    }
    
    @IBAction func saveTask(sender: NSButton) {
        let realm = try! Realm()
        try! realm.write {
            currentTask = realm.create(TicketTask.self, value: ["id": currentTask.id, "name": self.taskName.stringValue, "fromStationName": self.fromStationName.stringValue,"toStationName": self.toStationName.stringValue], update: true)
        }
        self.tasks[self.taskListTable.selectedRow] = currentTask
        let row = self.taskListTable.selectedRow
        self.taskListTable.reloadDataForRowIndexes(NSIndexSet(index: row), columnIndexes: NSIndexSet(index: 0))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromStationName.tableViewDelegate = self
        self.toStationName.tableViewDelegate = self
        
        let realm = try! Realm()
        let task = realm.objects(TicketTask)
        for var i = 0; i < task.count; i++ {
            self.tasks.append(task[i])
        }
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

extension TaskViewController:NSTableViewDelegate{
    func tableViewSelectionDidChange(notification: NSNotification) {
        let task = self.tasks[self.taskListTable.selectedRow]
        loadTask(task)
    }
    
    func loadTask(task:TicketTask){
        self.currentTask = task
        self.taskName.stringValue = task.name
        self.fromStationName.stringValue = task.fromStationName
        self.toStationName.stringValue = task.toStationName
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
