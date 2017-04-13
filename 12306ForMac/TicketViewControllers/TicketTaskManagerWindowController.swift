//
//  TicketTaskManagerWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 4/12/2017.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Cocoa

class TicketTask:NSObject {
    var startStation = "北京"
    var endStation = "上海"
    var date = "2017-04-22/2017-04-23/2017-04-24"
    
}

class TicketTaskManagerWindowController: BaseWindowController {
    
    override var windowNibName: String{
        return "TicketTaskManagerWindowController"
    }
    
    var calendarViewController:LunarCalendarView?
    
    @IBOutlet weak var ticketTaskTable: NSTableView!
    
    var calendarRow = -1
    
    var ticketTasks = [TicketTask]()

    override func windowDidLoad() {
        for i in 0...3 {
            let ticketTask = TicketTask()
            
            ticketTasks.append(ticketTask)
        }
        
    }
    
    @IBAction func clickOK(_ button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func getDatesByRow(_ row:Int) ->[Date] {
        var resDates = [Date]()
        let datesString = ticketTasks[row].date
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

extension TicketTaskManagerWindowController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ticketTasks.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return ticketTasks[row]
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
        
        let calendarPopover = NSPopover()
        let cp = LunarCalendarView(with:Date())
        calendarRow = self.ticketTaskTable.row(for: sender)
        cp.allSelectedDates = getDatesByRow(calendarRow)
        calendarPopover.contentViewController = cp
        calendarPopover.appearance = NSAppearance(named: "NSAppearanceNameAqua")
        calendarPopover.animates = true
        calendarPopover.behavior = NSPopoverBehavior.transient
        calendarPopover.delegate = self
        
        self.calendarViewController = cp
        let cellRect = sender.bounds
        calendarPopover.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    func popoverDidClose(_ notification: Notification) {
        let dates = calendarViewController!.allSelectedDates
        ticketTasks[calendarRow].date = convertDates2Str(dates)
        
        ticketTaskTable.reloadData()
    }
}
