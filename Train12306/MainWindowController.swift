//
//  MainWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController,NSTableViewDelegate,NSTableViewDataSource,NCRAutocompleteTableViewDelegate {
    
    @IBOutlet var fromStationName: NCRAutocompleteTextField!
    @IBOutlet var toStationName: NCRAutocompleteTextField!
    
    @IBOutlet weak var queryDate: NSDatePicker!
    @IBOutlet weak var leftTicketTable: NSTableView!
    
    var loginWindowController = LoginWindowController()
    var submitWindowController = PreOrderWindowController()
    
    var ticketQueryResult = [QueryLeftNewDTO]()
    var stationDataService = StationData()
    var httpService = HTTPService()
    
    @IBAction func UserLogin(sender: NSButton){
        loginWindowController.user.name = "fancymax"
        loginWindowController.user.passWord = "24834205"
        
        var windowController = loginWindowController
        
        if let window = window {
            //赋值原始的用户名，密码
            window.beginSheet(windowController.window!, completionHandler: {
                response in
                if response == NSModalResponseOK{
                    sender.title = windowController.user.name!
                }
                })
            loginWindowController = windowController
        }
    }
    
    @IBAction func submit(sender: NSButton){
        let selectedRow = leftTicketTable.rowForView(sender)
        httpService.checkUser()
        
        let ticket = ticketQueryResult[selectedRow]
        let dateStr = queryDate.dateValue.dateByAddingTimeInterval(86400).description
        let dateRange = dateStr.rangeOfString(" ")
        //日期需要＋1
        let date = dateStr[dateStr.startIndex..<dateRange!.startIndex]
        let fromStation = stationDataService.allStationMap[fromStationName.stringValue]?.Code
        let toStation = stationDataService.allStationMap[toStationName.stringValue]?.Code
        httpService.submitOrder(ticket.SecretStr!, trainDate: date, backTrainDate: "", queryFromStationName: fromStation!,queryToStationName: toStation!)
        
        var windowController = PreOrderWindowController()
        func openPreOrderWindowSheet(passengers:[PassengerDTO])
        {
            windowController.trainInfo = ticket
            windowController.passengerDTOs = passengers
            if let window = window {
                window.beginSheet(windowController.window!, completionHandler: {
                    response in
                    if response == NSModalResponseOK{
                        
                    }
                    
                    //???
                    })
                self.submitWindowController = windowController
            }
        }
        
        httpService.initDC(openPreOrderWindowSheet)
    }
    
    @IBAction func queryTicket(sender: NSButton) {
        let handler = {(leftTickets:[QueryLeftNewDTO]) -> () in
            self.ticketQueryResult = leftTickets
            self.leftTicketTable.reloadData()
        }
        
        let fromStation = stationDataService.allStationMap[fromStationName.stringValue]?.Code
        let toStation = stationDataService.allStationMap[toStationName.stringValue]?.Code
        
        let dateStr = queryDate.dateValue.dateByAddingTimeInterval(86400).description
        let dateRange = dateStr.rangeOfString(" ")
        //日期需要＋1
        let date = dateStr[dateStr.startIndex..<dateRange!.startIndex]
        println(fromStation)
        println(toStation)
        println(date)
        httpService.queryTicket(fromStation!,toStation:toStation!,date:date,successHandler:handler)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // The class of the window has been set in INAppStoreWindow in Interface Builder
        let aWindow = self.window as! INAppStoreWindow
        aWindow.titleBarHeight = 35
        let buttonSize = NSMakeSize(70, 30)
        let buttonFrame = NSMakeRect(100, 0, 100, 30)
        var loginButton = NSButton(frame: buttonFrame)
        loginButton.bezelStyle = .TexturedRoundedBezelStyle
        loginButton.target = self
        loginButton.title = "未登录"
        loginButton.action = "UserLogin:"
        
        
        aWindow.titleBarView.addSubview(loginButton)
        
        
        self.fromStationName.delegate = self
        self.toStationName.delegate = self
        self.fromStationName.stringValue = "深圳"
        self.toStationName.stringValue = "上海"
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return ticketQueryResult.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if(ticketQueryResult.count - 1 >= row)
        {
            return ticketQueryResult[row]
        }
        else
        {
            return nil
        }
    }
    
    func textField(textField: NSTextField!, completions words: [AnyObject]!, forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [AnyObject]! {
        var matches = [String]()
        //先按简拼  再按全拼  并保留上一次的match
        for station in stationDataService.allStation
        {
            if let range = station.FirstLetter.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
            {
                matches.append(station.Name)
            }
        }
        if(matches.count == 0)
        {
            for station in stationDataService.allStation
            {
                if let range = station.Spell.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
                {
                    matches.append(station.Name)
                }
            }
        }
        
        return matches
    }
    
    
}
