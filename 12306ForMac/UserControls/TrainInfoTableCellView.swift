//
//  TrainStationTableCellView.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainTableCellView: NSTableCellView {
    var ticketInfo: QueryLeftNewDTO! {
        didSet {
            updateUI()
        }
    }
    
    var selected = false
    //change color by backgroundStyle not selected status
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            updateTint()
        }
    }
    
    internal func updateUI() {
        
    }
    
    internal func updateTint() {
        if backgroundStyle == .dark {
            setSelectedControlStyle()
        }
        else{
            setUnSelectedControlStyle()
        }
    }
    
    internal func setSelectedControlStyle() {
        
    }
    
    internal func setUnSelectedControlStyle() {
        
    }
    
}

class TrainStationTableCellView: TrainTableCellView {
    
    @IBOutlet weak fileprivate var stationMarkField: NSTextField!
    @IBOutlet weak fileprivate var stationField: NSTextField!
    @IBOutlet weak fileprivate var timeField: NSTextField!

    override func setSelectedControlStyle() {
        stationMarkField.textColor = NSColor(calibratedWhite: 1.0, alpha: 0.70)
    }
    
    override func setUnSelectedControlStyle() {
        stationMarkField.textColor = NSColor(calibratedWhite: 0.0, alpha: 0.45)
    }
}

// MARK: - 发站
class StartStationTableCellView: TrainStationTableCellView {
    override func updateUI() {
        stationField.stringValue = ticketInfo.FromStationName!
        timeField.stringValue = ticketInfo.start_time!
        if ticketInfo.isStartStation {
            stationMarkField.isHidden = false
        }
        else{
            stationMarkField.isHidden = true
        }
    }
}

// MARK: - 到站
class EndStationTableCellView: TrainStationTableCellView {
    override func updateUI() {
        stationField.stringValue = ticketInfo.ToStationName!
        timeField.stringValue = ticketInfo.arrive_time!
        if ticketInfo.isEndStation {
            stationMarkField.isHidden = false
        }
        else {
            stationMarkField.isHidden = true
        }
    }
}

// MARK: - 车次
class TrainCodeTableCellView: TrainTableCellView {
    @IBOutlet weak fileprivate var trainCodeBtn: NSButton!
    
    func setTarget(_ target:AnyObject?, action:Selector){
            trainCodeBtn.target = target
            trainCodeBtn.action = action
    }
}

// MARK: - 余票信息
class TrainInfoTableCellView: TrainTableCellView {
    @IBOutlet weak fileprivate var messageField: NSTextField!
    @IBOutlet weak fileprivate var SwzBtn: NSButton!
    @IBOutlet weak fileprivate var TzBtn: NSButton!
    @IBOutlet weak fileprivate var ZyBtn: NSButton!
    @IBOutlet weak fileprivate var ZeBtn: NSButton!
    @IBOutlet weak fileprivate var GrBtn: NSButton!
    @IBOutlet weak fileprivate var RwBtn: NSButton!
    @IBOutlet weak fileprivate var YwBtn: NSButton!
    @IBOutlet weak fileprivate var RzBtn: NSButton!
    @IBOutlet weak fileprivate var YzBtn: NSButton!
    @IBOutlet weak fileprivate var WzBtn: NSButton!
    
    var dictOfBtn:[Int:NSButton]{
        get {
            return [1: SwzBtn, 2: TzBtn, 3: ZyBtn, 4: ZeBtn, 5: GrBtn, 6: RwBtn, 7: YwBtn, 8: RzBtn, 9: YzBtn, 10: WzBtn]
        }
    }
    
    func setTarget(_ target:AnyObject?, action:Selector){
        for btn in dictOfBtn.values {
            btn.target = target
            btn.action = action
        }
    }
    
    override func setSelectedControlStyle() {
        messageField.textColor = NSColor(calibratedWhite: 1.0, alpha: 0.70)
        
        for btn in dictOfBtn.values {
            (btn as! LoginButton).textColor = NSColor(calibratedWhite: 1.0, alpha: 1)
        }
    }
    
    override func setUnSelectedControlStyle() {
        messageField.textColor = NSColor(calibratedWhite: 0.0, alpha: 0.45)
        
        for btn in dictOfBtn.values {
            (btn as! LoginButton).textColor = NSColor(calibratedRed: 0.270588, green: 0.541176, blue: 0.913725, alpha: 1.0)
        }
    }
    
    override func updateUI() {
        
        func setTicketButton(_ ticket:String,sender:NSButton){
            if ((ticket == "--")||(ticket == "无")||(ticket == "*")){
                sender.isHidden = true
                return
            }
            
            sender.isHidden = false
            sender.isEnabled = true
            if (ticket == "有"){
                sender.title = sender.alternateTitle + "(有票)"
            }
            else{
                sender.title = sender.alternateTitle + "(\(ticket)张)"
            }
            
        }
        
        setTicketButton(ticketInfo.Swz_Num, sender: SwzBtn)
        setTicketButton(ticketInfo.Tz_Num, sender: TzBtn)
        setTicketButton(ticketInfo.Zy_Num, sender: ZyBtn)
        setTicketButton(ticketInfo.Ze_Num, sender: ZeBtn)
        setTicketButton(ticketInfo.Gr_Num, sender: GrBtn)
        setTicketButton(ticketInfo.Rw_Num, sender: RwBtn)
        setTicketButton(ticketInfo.Yw_Num, sender: YwBtn)
        setTicketButton(ticketInfo.Rz_Num, sender: RzBtn)
        setTicketButton(ticketInfo.Yz_Num, sender: YzBtn)
        setTicketButton(ticketInfo.Wz_Num, sender: WzBtn)
        
        if ticketInfo.canWebBuy == "Y" {
            messageField.isHidden = true
        }
        else if ticketInfo.canWebBuy == "N" {
            messageField.stringValue = "   本车次暂无可售车票"
            messageField.isHidden = false
        }
        else if ticketInfo.canWebBuy == "IS_TIME_NOT_BUY"{
            
            for btn in dictOfBtn.values {
                btn.isEnabled = false
            }
            
            if ticketInfo.buttonTextInfo == "23:00-06:00系统维护时间" {
                if ticketInfo.hasTicket {
                    messageField.isHidden = true
                }
                else{
                    messageField.stringValue = "   本车次暂无可售车票"
                    messageField.isHidden = false
                }
            }
            else
            {
                if let range = ticketInfo.buttonTextInfo!.range(of: "<br/>"){
                    ticketInfo.buttonTextInfo!.removeSubrange(range)
                }
                messageField.stringValue = "   " + ticketInfo.buttonTextInfo!
                messageField.isHidden = false
            }
        }
    }
}
