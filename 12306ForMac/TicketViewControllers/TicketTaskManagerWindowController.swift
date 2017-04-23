//
//  TicketTaskManagerWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 4/12/2017.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Cocoa
import SwiftyJSON

class TicketTask:NSObject {
    var startStation = "北京"
    var endStation = "上海"
    var date = "2017-04-22"
    
    override init() {
        super.init()
        date = getDateStr(Date())
    }
    
    convenience init(json:JSON) {
        self.init()
        decodeJsonFrom(json)
    }
    
    func getDateStr(_ date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
    }
    
    func encodeToJson() ->JSON {
        let json:JSON = [#keyPath(startStation):startStation,#keyPath(endStation):endStation,#keyPath(date):date]
        
        return json
    }
    
    func decodeJsonFrom(_ json:JSON) {
        let startStationKeyPath = #keyPath(startStation)
        startStation = json[startStationKeyPath].stringValue
        
        let endStationKeyPath = #keyPath(endStation)
        endStation = json[endStationKeyPath].stringValue
        
        let dateKeyPath = #keyPath(date)
        date = json[dateKeyPath].stringValue
    }
}

class TicketTasksManager: NSObject {
    var ticketTasks = [TicketTask]()
    
    func encodeToJsonString() -> String {
        var json:[JSON] = [JSON]()
        for i in 0..<ticketTasks.count {
            json.append(ticketTasks[i].encodeToJson())
        }
        
        return JSON(json).rawString()!
    }
    
    func decodeJsonFrom(_ jsonString:String) {
        ticketTasks = [TicketTask]()
        if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            if json.array == nil {
                return
            }
            for item in json.array! {
                let ticketTask = TicketTask(json:item)
                ticketTasks.append(ticketTask)
            }
        }
    }
    
    func addTicketTask() {
        let newTask = TicketTask()
        let taskCount = ticketTasks.count
        if taskCount != 0 {
            let json = ticketTasks[taskCount - 1].encodeToJson()
            newTask.decodeJsonFrom(json)
        }
        ticketTasks.append(newTask)
    }
    
    func deleteTicketTask(_ index:Int) {
        let taskCount = ticketTasks.count
        if index < taskCount && taskCount > 0 {
            ticketTasks.remove(at: index)
        }
    }
    
}

class TicketTaskManagerWindowController: BaseWindowController {
    
    @IBOutlet weak var ticketTaskTable: NSTableView!
    
    var calendarViewController:LunarCalendarView?
    
    var calendarRow = -1
    
    var ticketTasksManager = TicketTasksManager()
    
    var isShowCalendarPopover = false

    override var windowNibName: String{
        return "TicketTaskManagerWindowController"
    }
    
    override func windowDidLoad() {
        let lastTicketJsonString = QueryDefaultManager.sharedInstance.lastTicketTaskManager
        if lastTicketJsonString != nil {
            ticketTasksManager.decodeJsonFrom(lastTicketJsonString!)
        }
        
        self.window?.makeFirstResponder(ticketTaskTable)
        ticketTaskTable.selectRowIndexes(IndexSet(integer:0), byExtendingSelection: false)
    }
    
    func getDatesByRow(_ row:Int) ->[Date] {
        var resDates = [Date]()
        let datesString = ticketTasksManager.ticketTasks[row].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for dateStr in datesString.components(separatedBy: "/") {
            if let date = dateFormatter.date(from: dateStr) {
                resDates.append(date)
            }
        }
    
        return resDates
    }
    
    func convertDates2Str(_ dates:[Date]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var resStr = ""
        for i in 0...dates.count - 1 {
            let str = dateFormatter.string(from: dates[i])
            resStr.append(str)
            if i != dates.count - 1 {
                resStr.append("/")
            }
        }
        
        return resStr
    }
    
    // MARK: - click Action
    @IBAction func clickOK(_ button:NSButton){
        QueryDefaultManager.sharedInstance.lastTicketTaskManager = ticketTasksManager.encodeToJsonString()
        
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    @IBAction func clickAddTask(_ sender: NSButton) {
        ticketTasksManager.addTicketTask()
        
        let index = ticketTaskTable.selectedRow
        ticketTaskTable.reloadData()
        ticketTaskTable.selectRowIndexes(IndexSet(arrayLiteral:index), byExtendingSelection: false)
    }

    @IBAction func clickDeleteTask(_ sender: NSButton) {
        let index = ticketTaskTable.selectedRow
        ticketTasksManager.deleteTicketTask(index)
        
        ticketTaskTable.reloadData()
        if index - 1 >= 0 {
            ticketTaskTable.selectRowIndexes(IndexSet(arrayLiteral:index - 1), byExtendingSelection: false)
        }
    }
}

// MARK: - AutoCompleteTableViewDelegate
extension TicketTaskManagerWindowController: AutoCompleteTableViewDelegate{
    func textField(_ textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        var matches = [String]()
        //先按简拼  再按全拼  并保留上一次的match
        for station in StationNameJs.sharedInstance.allStation
        {
            if let _ = station.FirstLetter.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
            {
                matches.append(station.Name)
            }
        }
        
        if(matches.isEmpty)
        {
            for station in StationNameJs.sharedInstance.allStation
            {
                if let _ = station.Spell.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
                {
                    matches.append(station.Name)
                }
            }
        }
        
        return matches
    }
}

// MARK: - NSTableViewDataSource
extension TicketTaskManagerWindowController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ticketTasksManager.ticketTasks.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return ticketTasksManager.ticketTasks[row]
    }
}

// MARK: - NSTableViewDelegate
extension TicketTaskManagerWindowController: NSTableViewDelegate{
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let columnIdentifier = tableColumn!.identifier
        if(columnIdentifier == "startStation" || columnIdentifier == "endStation"){
            let cell = view.viewWithTag(1) as! AutoCompleteTextField
            cell.tableViewDelegate = self
        }
        else if (columnIdentifier == "date") {
            let cell = view.viewWithTag(1) as! NSButton
            cell.target = self
            cell.action = #selector(showCalendar(_:))
        }
        
        return view
    }
}

// MARK: - NSPopoverDelegate
extension TicketTaskManagerWindowController:NSPopoverDelegate {
    
    @IBAction func showCalendar(_ sender: NSButton){
        if isShowCalendarPopover {
            return
        }
        
        let calendarPopover = NSPopover()
        let cp = LunarCalendarView(with:Date())
        calendarRow = self.ticketTaskTable.row(for: sender)
        
        cp.allSelectedDates = getDatesByRow(calendarRow)
        calendarPopover.contentViewController = cp
        calendarPopover.appearance = NSAppearance(named: "NSAppearanceNameAqua")
        calendarPopover.animates = true
        calendarPopover.behavior = NSPopoverBehavior.transient
        calendarPopover.delegate = self
        
        self.ticketTaskTable.selectRowIndexes(IndexSet(integer:calendarRow), byExtendingSelection: false)
        
        isShowCalendarPopover = true
        
        self.calendarViewController = cp
        let cellRect = sender.bounds
        calendarPopover.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    func popoverDidClose(_ notification: Notification) {
        let dates = calendarViewController!.allSelectedDates
        ticketTasksManager.ticketTasks[calendarRow].date = convertDates2Str(dates)
        isShowCalendarPopover = false
        
        ticketTaskTable.reloadData()
        ticketTaskTable.selectRowIndexes(IndexSet(integer:calendarRow), byExtendingSelection: false)
    }
}
