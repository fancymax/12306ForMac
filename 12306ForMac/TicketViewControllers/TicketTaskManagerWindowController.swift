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
    var date = "2017-01-02"
    
}

class TicketTaskManagerWindowController: BaseWindowController {
    
    override var windowNibName: String{
        return "TicketTaskManagerWindowController"
    }
    
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
        if(columnIdentifier == "AutomaticTableColumnIdentifier.0"){
            let cell = view.viewWithTag(1) as! AutoCompleteTextField
            cell.tableViewDelegate = self
        }
        
        return view
    }
}
