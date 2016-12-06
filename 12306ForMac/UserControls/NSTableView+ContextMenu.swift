//
//  NSTableView+ContextMenu.swift
//  12306ForMac
//
//  Created by fancymax on 2016/12/6.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

//user define Context Menu
protocol ContextMenuDelegate: NSObjectProtocol {
    func tableView(aTableView:NSTableView, menuForRows rows:IndexSet) -> NSMenu?
}

extension NSTableView {
    
    open override func menu(for event: NSEvent) -> NSMenu? {

        let location = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: location)
        if ((row < 0) || (event.type != NSRightMouseDown)) {
            return super.menu(for: event)
        }
        
        var selected = self.selectedRowIndexes
        if !selected.contains(row) {
            selected = IndexSet(integer:row)
            self.selectRowIndexes(selected, byExtendingSelection: false)
        }
        
        if let contextMenuDelegate = self.delegate {
            if contextMenuDelegate.responds(to: Selector(("tableView:menuForRows:"))){
                return (contextMenuDelegate as! ContextMenuDelegate).tableView(aTableView: self,menuForRows:selected)
            }
        }
        
        return super.menu(for: event)
    }
    
}
