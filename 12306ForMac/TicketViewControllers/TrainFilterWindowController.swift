//
//  TrainFilterWindowController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/2.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class DemoModel: NSObject {
    init(type:Int,key:String,isChecked:Bool) {
        self.type = type
        self.key = key
        self.isChecked = isChecked
    }
    var type = 0
    var key = ""
    var isChecked = false
}

class TrainFilterWindowController: NSWindowController,NSTableViewDelegate,NSTableViewDataSource {
    
    var demos = [DemoModel]()
    
    func initDemos() {
        demos.append(DemoModel(type: 0,key: "席别类型",isChecked: false))
        demos.append(DemoModel(type: 1,key: "商务座",isChecked: false))
        demos.append(DemoModel(type: 1,key: "特等座",isChecked: false))
        demos.append(DemoModel(type: 1,key: "一等座",isChecked: false))
        demos.append(DemoModel(type: 1,key: "二等座",isChecked: false))
        demos.append(DemoModel(type: 1,key: "高级软卧",isChecked: false))
        demos.append(DemoModel(type: 1,key: "软卧",isChecked: false))
        demos.append(DemoModel(type: 1,key: "硬卧",isChecked: false))
        demos.append(DemoModel(type: 1,key: "硬座",isChecked: false))
        demos.append(DemoModel(type: 1,key: "无座",isChecked: false))
        demos.append(DemoModel(type: 0,key: "出发时段",isChecked: false))
        demos.append(DemoModel(type: 2,key: "00:00--06:00",isChecked: false))
        demos.append(DemoModel(type: 2,key: "06:00--12:00",isChecked: false))
        demos.append(DemoModel(type: 2,key: "12:00--18:00",isChecked: false))
        demos.append(DemoModel(type: 2,key: "18:00--24:00",isChecked: false))
        demos.append(DemoModel(type: 0,key: "车次类型",isChecked: false))
        demos.append(DemoModel(type: 3,key: "GC高铁/城际",isChecked: false))
        demos.append(DemoModel(type: 3,key: "D动车",isChecked: false))
        demos.append(DemoModel(type: 3,key: "Z字头",isChecked: false))
        demos.append(DemoModel(type: 3,key: "T字头",isChecked: false))
        demos.append(DemoModel(type: 3,key: "K字头",isChecked: false))
        demos.append(DemoModel(type: 3,key: "其它(L/Y)",isChecked: false))
        demos.append(DemoModel(type: 0,key: "指定车次",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D1234 北京南 - 上海 19:34~07:41 历时12:07",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
        demos.append(DemoModel(type: 4,key: "D2683 北京 - 上海 21:23~09:13 历时11:50",isChecked: false))
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        print(demos.count)
        return demos.count
    }
    
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if demos[row].type == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if demos[row].type == 0 {
            return tableView.makeViewWithIdentifier("TextCell", owner: nil)
        }
        else{
            return tableView.makeViewWithIdentifier("MainCell", owner: nil)
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return demos[row]
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if demos[row].type == 0 {
            return 20
        }
        else if demos[row].type != 4 {
            return 25
        }
        else{
            return 40
        }
        
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        initDemos()
    }
    
    override var windowNibName: String{
        return "TrainFilterWindowController"
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}
