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
    
    private func updateUI() {
        
    }
    
    func updateTint() {
        if selected {
            stationMarkField.textColor = NSColor(calibratedWhite: 1.0, alpha: 0.70)
        }
        else{
            stationMarkField.textColor = NSColor(calibratedWhite: 0.0, alpha: 0.70)
        }
    }
    
}
