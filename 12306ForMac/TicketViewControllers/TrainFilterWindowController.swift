//
//  TrainFilterWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/2.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class FilterItem: NSObject {
    init(type:FilterItemType,key:String,presentation:String,isChecked:Bool) {
        self.type = type
        self.presentation = presentation
        self.key = key
        self.isChecked = isChecked
    }
    let type:FilterItemType
    let key:String
    let presentation:String
    var isChecked:Bool
}

enum FilterItemType:Int {
    case Group = 0, SeatType, StartTime, TrainType, Train
}

class TrainFilterWindowController: NSWindowController {
    
    var trains:[QueryLeftNewDTO]?
    var filterItems = [FilterItem]()
    var fromStationName = ""
    var toStationName = ""
    var trainDate = ""
    
    var trainFilterKey = ""
    var seatFilterKey = ""
    
    @IBOutlet weak var trainFilterTable: NSTableView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        createFilterItemByTrains(trains!)
    }
    
    override var windowNibName: String{
        return "TrainFilterWindowController"
    }
    
    func createFilterItemByTrains(_ trains:[QueryLeftNewDTO]){
        filterItems.append(FilterItem(type: .Group,key:"",presentation: "席别类型",isChecked: false))
        filterItems.append(FilterItem(type: .SeatType,key:"9|P|O|4|6",presentation: "商务座|特等座|软卧|高级软卧",isChecked: false))
        filterItems.append(FilterItem(type: .SeatType,key:"M",presentation: "一等座|硬卧",isChecked: false))
        filterItems.append(FilterItem(type: .SeatType,key:"O|1",presentation: "二等座|硬座",isChecked: true))
        filterItems.append(FilterItem(type: .SeatType,key:"1|O",presentation: "无座",isChecked: false))
        filterItems.append(FilterItem(type: .Group,key:"",presentation: "出发时段",isChecked: false))
        filterItems.append(FilterItem(type: .StartTime,key:"00:00|06:00",presentation: "00:00--06:00",isChecked: true))
        filterItems.append(FilterItem(type: .StartTime,key:"06:00|12:00",presentation: "06:00--12:00",isChecked: true))
        filterItems.append(FilterItem(type: .StartTime,key:"12:00|18:00",presentation: "12:00--18:00",isChecked: true))
        filterItems.append(FilterItem(type: .StartTime,key:"18:00|24:00",presentation: "18:00--24:00",isChecked: true))
        filterItems.append(FilterItem(type: .Group,key:"",presentation: "车次类型",isChecked: false))
        filterItems.append(FilterItem(type: .TrainType,key:"G|C|D",presentation: "G高铁|C城际|D动车",isChecked: true))
        filterItems.append(FilterItem(type: .TrainType,key:"Z|T",presentation: "Z直达|T特快",isChecked: true))
        filterItems.append(FilterItem(type: .TrainType,key:"K|L|Y",presentation: "K快车|LY临客",isChecked: true))
        filterItems.append(FilterItem(type: .Group,key:"",presentation: "指定车次",isChecked: true))
        
        for train in trains {
            let key = "\(train.TrainCode!)|\(train.start_time!)"
            let presentation = "\(train.TrainCode!) |1\(train.start_time!)~\(train.arrive_time!)  |2\(train.FromStationName!)->\(train.ToStationName!)"
            filterItems.append(FilterItem(type: .Train, key: key, presentation: presentation, isChecked: true))
        }
    }
    
    func getFilterKey(){
        trainFilterKey = "|"
        seatFilterKey = "|"
        for item in filterItems {
            if ((item.type == .Train) && (item.isChecked)) {
                trainFilterKey += "\(item.key)|"
            }
            
            if ((item.type == .SeatType) && (item.isChecked)) {
                seatFilterKey += "\(item.presentation)|"
            }
        }
    }
    
    func dismissWithModalResponse(_ response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
    
    @IBAction func clickTrainFilterBtn(_ sender: NSButton) {
        let row = trainFilterTable.row(for: sender)
        let item = filterItems[row]
        
        var changeState = false
        if sender.state == NSOnState {
            changeState = true
        }
        else {
            changeState = false
        }
        
        if item.type == .StartTime {
            let filterKeys = item.key.components(separatedBy: "|")
            for item in filterItems where item.type == .Train {
                let startTime = item.key.components(separatedBy: "|")[1]
                if ((startTime >= filterKeys[0]) && (startTime <= filterKeys[1])) {
                    item.isChecked = changeState
                }
            }
        }
        
        if item.type == .TrainType {
            let filterKeys = item.key.components(separatedBy: "|")
            for item in filterItems where item.type == .Train {
                for filterKey in filterKeys {
                    if item.key.contains(filterKey) {
                        item.isChecked = changeState
                    }
                }
            }
        }
        trainFilterTable.reloadData()
    }
    
    @IBAction func clickCancel(_ sender: AnyObject) {
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    @IBAction func clickOK(_ sender: AnyObject) {
        getFilterKey()
        dismissWithModalResponse(NSModalResponseOK)
    }
}

// MARK: - NSTableViewDelegate / NSTableViewDataSource
extension TrainFilterWindowController:NSTableViewDelegate,NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return filterItems[row]
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filterItems.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if filterItems[row].type == .Group {
            return 20
        }
        else{
            return 25
        }
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if filterItems[row].type == .Group {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let mainCell:NSView?
        if filterItems[row].type == .Group {
            mainCell = tableView.make(withIdentifier: "TextCell", owner: nil)
        }
        else if filterItems[row].type == .Train {
            mainCell = tableView.make(withIdentifier: "TrainInfoCell", owner: nil)
        }
        else{
            mainCell = tableView.make(withIdentifier: "MainCell", owner: nil)
        }
        if let view = mainCell?.viewWithTag(100) {
            let btn = view as! NSButton
            btn.target = self
            btn.action = #selector(TrainFilterWindowController.clickTrainFilterBtn(_:))
        }
        
        return mainCell
    }

}
