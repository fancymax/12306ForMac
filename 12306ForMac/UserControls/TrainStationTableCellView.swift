//
//  TrainStationTableCellView.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainStationTableCellView: NSTableCellView {
    
    @IBOutlet weak private var stationMarkField: NSTextField!
    @IBOutlet weak private var stationField: NSTextField!
    @IBOutlet weak private var timeField: NSTextField!
    var ticketInfo: QueryLeftNewDTO! {
        didSet {
            updateUI()
        }
    }

    var selected = false {
        didSet{
            updateTint()
        }
    }
    
    override var backgroundStyle: NSBackgroundStyle {
        didSet{
            stationMarkField.cell?.backgroundStyle = .Light
        }
    }
    
    internal func updateUI() {
        
    }
    
    private func updateTint() {
        if selected {
            stationMarkField.textColor = NSColor(calibratedWhite: 1.0, alpha: 0.70)
        }
        else{
            stationMarkField.textColor = NSColor(calibratedWhite: 0.0, alpha: 0.70)
        }
    }
    
}

class StartStationTableCellView: TrainStationTableCellView {
    override func updateUI() {
        stationField.stringValue = ticketInfo.FromStationName!
        timeField.stringValue = ticketInfo.start_time!
        if ticketInfo.isStartStation {
            stationMarkField.hidden = false
        }
        else{
            stationMarkField.hidden = true
        }
    }
}

class EndStationTableCellView: TrainStationTableCellView {
    override func updateUI() {
        stationField.stringValue = ticketInfo.ToStationName!
        timeField.stringValue = ticketInfo.arrive_time!
        if ticketInfo.isEndStation {
            stationMarkField.hidden = false
        }
        else {
            stationMarkField.hidden = true
        }
    }
}
