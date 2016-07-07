//
//  TrainTableRowView.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainTableRowView: NSTableRowView {
    
    private var shouldDrawAsKey = true
    
    override var selected: Bool {
        didSet {
            updateSubviewsInterestedInSelectionState()
        }
    }

    private func updateSubviewsInterestedInSelectionState() {
        guard subviews.count > 0 else { return }
        
        for view in subviews {
            if view.isKindOfClass(TrainTableCellView) {
                let stationCellView = view as! TrainTableCellView
                stationCellView.selected = selected
            }
        }
    }
    
}
