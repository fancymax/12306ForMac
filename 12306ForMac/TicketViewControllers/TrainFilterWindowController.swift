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
    
    func createFilterItemByTrains(_ trains:[QueryLeftNewDTO]){
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "席别类型",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"9|P|O|4|6",presentation: "商务座|特等座|软卧|高级软卧",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"M",presentation: "一等座|硬卧",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 1,key:"O|1",presentation: "二等座|硬座",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 1,key:"1|O",presentation: "无座",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "出发时段",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 2,key:"00:00|06:00",presentation: "00:00--06:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 2,key:"06:00|12:00",presentation: "06:00--12:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 2,key:"12:00|18:00",presentation: "12:00--18:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 2,key:"18:00|24:00",presentation: "18:00--24:00",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "车次类型",isChecked: false))
        filterItems.append(FilterPresentationItem(type: 3,key:"G|C|D",presentation: "G高铁|C城际|D动车",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"Z|T",presentation: "Z直达|T特快",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 3,key:"K|L|Y",presentation: "K快车|LY临客",isChecked: true))
        filterItems.append(FilterPresentationItem(type: 0,key:"",presentation: "指定车次",isChecked: true))
        //demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        
        for train in trains {
            let key = "\(train.TrainCode!)|\(train.start_time!)"
            let presentation = "\(train.TrainCode!) |1\(train.start_time!)~\(train.arrive_time!)  |2\(train.FromStationName!)->\(train.ToStationName!)"
            filterItems.append(FilterPresentationItem(type: 4, key: key, presentation: presentation, isChecked: true))
        }
        
    }
    
    func getFilterKey(){
        trainFilterKey = "|"
        seatFilterKey = "|"
        for item in filterItems {
            if ((item.type == 4) && (item.isChecked)) {
                trainFilterKey += "\(item.key)|"
            }
            
            if ((item.type == 1) && (item.isChecked)) {
                seatFilterKey += "\(item.presentation)|"
            }
        }
    }
    
    @IBAction func checkTrainFilter(_ sender: NSButton) {
        let row = trainFilterTable.row(for: sender)
        let item = filterItems[row]
        
        var changeState = false
        if sender.state == NSOnState {
            changeState = true
        }
        else {
            changeState = false
        }
        
        if item.type == 2 {
            let filterKeys = item.key.components(separatedBy: "|")
            for item in filterItems where item.type == 4 {
                let startTime = item.key.components(separatedBy: "|")[1]
                if ((startTime >= filterKeys[0]) && (startTime <= filterKeys[1])) {
                    item.isChecked = changeState
                }
            }
        }
        
        if item.type == 3 {
            let filterKeys = item.key.components(separatedBy: "|")
            for item in filterItems where item.type == 4 {
                for filterKey in filterKeys {
                    if item.key.contains(filterKey) {
                        item.isChecked = changeState
                    }
                }
            }
        }
        trainFilterTable.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filterItems.count
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if filterItems[row].type == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if filterItems[row].type == 0 {
            return tableView.make(withIdentifier: "TextCell", owner: nil)
        }
        else if filterItems[row].type == 4 {
            let mainCell = tableView.make(withIdentifier: "TrainInfoCell", owner: nil)
            
            let button = mainCell?.viewWithTag(100) as! NSButton
            button.target = self
            button.action = #selector(TrainFilterWindowController.checkTrainFilter(_:))
            
            return mainCell
        }
        else{
            let mainCell = tableView.make(withIdentifier: "MainCell", owner: nil)
            
            let button = mainCell?.viewWithTag(100) as! NSButton
            button.target = self
            button.action = #selector(TrainFilterWindowController.checkTrainFilter(_:))
            
            return mainCell
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return filterItems[row]
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
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
    
    @IBAction func clickCancel(_ sender: AnyObject) {
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    @IBAction func clickOK(_ sender: AnyObject) {
        getFilterKey()
        dismissWithModalResponse(NSModalResponseOK)
    }
    
    func dismissWithModalResponse(_ response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}
