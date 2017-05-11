//
//  TrainTableRowView.swift
//  12306ForMac
//
//  Created by fancymax on 16/6/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainTableRowView: NSTableRowView {
    
    override var isOpaque: Bool {
        return false
    }
    
    override var isSelected: Bool {
        didSet {
            updateSubviewsInterestedInSelectionState()
        }
    }

    fileprivate func updateSubviewsInterestedInSelectionState() {
        guard subviews.count > 0 else { return }
        
        for view in subviews {
            if view.isKind(of: TrainTableCellView.self) {
                let stationCellView = view as! TrainTableCellView
                stationCellView.selected = isSelected
            }
        }
    }
    
}
