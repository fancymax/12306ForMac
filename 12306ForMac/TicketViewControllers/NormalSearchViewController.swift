//
//  NormalSearchViewController.swift
//  Train12306
//
//  Created by fancymax on 15/9/29.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

class NormalSearchViewController: NSViewController {
    
    @IBOutlet weak var fromStationName: AutoCompleteTextField!
    @IBOutlet weak var toStationName: AutoCompleteTextField!
    @IBOutlet weak var queryDate: NSDatePicker!
    
    var calendarPopover:NSPopover?
    var stationDataService = StationData()
    var ticketTableDelegate:TicketTableDelegate?
    var lastUserDefault = UserDefaultManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fromStationName.tableViewDelegate = self
        self.toStationName.tableViewDelegate = self
        
        self.fromStationName.stringValue = lastUserDefault.lastFromStation!
        self.toStationName.stringValue = lastUserDefault.lastToStation!
        
        self.queryDate.dateValue = lastUserDefault.lastQueryDate!.laterDate(NSDate())
    }
    
    @IBAction func convertCity(sender: NSButton) {
        let temp = self.fromStationName.stringValue
        self.fromStationName.stringValue = self.toStationName.stringValue
        self.toStationName.stringValue = temp
    }
    
    func createCalenderPopover(){
        var myPopover = self.calendarPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            let cp = LunarCalendarView()
            cp.delegate = self
            cp.date = self.queryDate.dateValue
            cp.selectedDate = self.queryDate.dateValue
            myPopover!.contentViewController = cp
            myPopover!.appearance = NSAppearance(named: "NSAppearanceNameAqua")
            myPopover!.animates = true
            myPopover!.behavior = NSPopoverBehavior.Transient
        }
        self.calendarPopover = myPopover
    }
    
    @IBAction func showCalendar(sender: AnyObject){
        self.createCalenderPopover()
        let cellRect = sender.bounds
        self.calendarPopover?.showRelativeToRect(cellRect, ofView: sender as! NSView, preferredEdge: .MaxY)
    }
    
    @IBAction func queryTicket(sender: NSButton) {
        if !stationDataService.allStationMap.keys.contains(fromStationName.stringValue) {
            print("error fromStationName: \(fromStationName.stringValue)")
            return
            
        }
        
        if !stationDataService.allStationMap.keys.contains(toStationName.stringValue) {
            print("error toStationName: \(toStationName.stringValue)")
            return
        }
        
        let fromStation = stationDataService.allStationMap[fromStationName.stringValue]?.Code
        let toStation = stationDataService.allStationMap[toStationName.stringValue]?.Code

        let dateStr = queryDate.dateValue.description
        let dateRange = dateStr.rangeOfString(" ")
        let date = dateStr[dateStr.startIndex..<dateRange!.startIndex]
        
        lastUserDefault.lastFromStation = fromStationName.stringValue
        lastUserDefault.lastToStation = toStationName.stringValue
        lastUserDefault.lastQueryDate = queryDate.dateValue
        
        print("\(fromStation) \(toStation) \(date)")
        ticketTableDelegate?.queryLeftTicket(fromStation!, toStationCode: toStation!, date: date)
    }
}

// MARK: - AutoCompleteTableViewDelegate
extension NormalSearchViewController: AutoCompleteTableViewDelegate{
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

// MARK: - LunarCalendarViewDelegate
extension NormalSearchViewController: LunarCalendarViewDelegate{
    func didSelectDate(selectedDate: NSDate) {
        self.queryDate!.dateValue = selectedDate
        self.calendarPopover?.close()
    }
}
