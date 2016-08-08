//
//  TrainFilterWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/2.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class FilterPresentationItem: NSObject {
    init(type:Int,key:String,presentation:String,isChecked:Bool) {
        self.type = type
        self.presentation = presentation
        self.key = key
        self.isChecked = isChecked
    }
    var type = 0
    var key = ""
    var presentation = ""
    var isChecked = false
}

class TrainFilterWindowController: NSWindowController,NSTableViewDelegate,NSTableViewDataSource {
    
    var trains:[QueryLeftNewDTO]?
    var filterItems = [FilterPresentationItem]()
    var fromStationName = ""
    var toStationName = ""
    var trainDate = ""
    
    var trainFilterKey = ""
    var seatFilterKey = ""
        
    @IBOutlet weak var trainFilterTable: NSTableView!
    
    func createFilterItemByTrains(trains:[QueryLeftNewDTO]){
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "席别类型",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"9",presentation: "商务座",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"P",presentation: "特等座",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"M",presentation: "一等座",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"O",presentation: "二等座",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 1,key:"6",presentation: "高级软卧",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"O|4",presentation: "软卧",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"3",presentation: "硬卧",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"1",presentation: "硬座",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 1,key:"1|O",presentation: "无座",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "出发时段",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 2,key:"00|06",presentation: "00:00--06:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 2,key:"06|12",presentation: "06:00--12:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 2,key:"12|18",presentation: "12:00--18:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 2,key:"18|24",presentation: "18:00--24:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "车次类型",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 3,key:"G|C",presentation: "GC高铁/城际",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"D",presentation: "D动车",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"Z",presentation: "Z字头",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"T",presentation: "T字头",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"K",presentation: "K字头",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"L|Y",presentation: "其它(L/Y)",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "指定车次",isChecked: true))
        //demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        
        for train in trains {
            let key = "\(train.TrainCode!)|\(train.start_time!)"
            let presentation = "\(train.TrainCode!) \(train.FromStationName!)->\(train.ToStationName!) \(train.start_time!)~\(train.arrive_time!)"
            filterItems.append(FilterPresentationItem(type: 4, key: key, presentation: presentation, isChecked: true))
        }
        
    }
    
    func getFilterKey(){
        trainFilterKey = ""
        seatFilterKey = ""
        for item in filterItems {
            if ((item.type == 4) && (item.isChecked)) {
                trainFilterKey += "\(item.key)|"
            }
            
            if ((item.type == 1) && (item.isChecked)) {
                seatFilterKey += "\(item.key)|"
            }
        }
    }
    
    @IBAction func checkTrainFilter(sender: NSButton) {
        let row = trainFilterTable.rowForView(sender)
        let item = filterItems[row]
        
        var changeState = false
        if sender.state == NSOnState {
            changeState = true
        }
        else {
            changeState = false
        }
        
        if item.type == 2 {
            let filterKeys = item.key.componentsSeparatedByString("|")
            for item in filterItems where item.type == 4 {
                let startTime = item.key.componentsSeparatedByString("|")[1]
                if ((startTime >= filterKeys[0]) && (startTime <= filterKeys[1])) {
                    item.isChecked = changeState
                }
            }
        }
        
        if item.type == 3 {
            let filterKeys = item.key.componentsSeparatedByString("|")
            for item in filterItems where item.type == 4 {
                for filterKey in filterKeys {
                    if item.key.containsString(filterKey) {
                        item.isChecked = changeState
                    }
                }
            }
        }
        trainFilterTable.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filterItems.count
    }
    
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if filterItems[row].type == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if filterItems[row].type == 0 {
            return tableView.makeViewWithIdentifier("TextCell", owner: nil)
        }
        else{
            let mainCell = tableView.makeViewWithIdentifier("MainCell", owner: nil)
            
            let button = mainCell?.viewWithTag(100) as! NSButton
            button.target = self
            button.action = #selector(TrainFilterWindowController.checkTrainFilter(_:))
            
            return mainCell
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return filterItems[row]
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if filterItems[row].type == 0 {
            return 20
        }
        else{
            return 25
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        createFilterItemByTrains(trains!)
    }
    
    override var windowNibName: String{
        return "TrainFilterWindowController"
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    @IBAction func okButtonClicked(button:NSButton){
        getFilterKey()
        dismissWithModalResponse(NSModalResponseOK)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}
