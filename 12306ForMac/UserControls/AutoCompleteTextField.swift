//
//  AutoCompleteTextField.swift
//  AutoCompleteTextFieldDemo
//
//  Created by fancymax on 15/12/12.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

@objc protocol AutoCompleteTableViewDelegate:NSObjectProtocol{
    func textField(textField:NSTextField,completions words:[String],forPartialWordRange charRange:NSRange,indexOfSelectedItem index:Int) ->[String]
    optional func didSelectItem(selectedItem: String)
}

class AutoCompleteTableRowView:NSTableRowView{
    override func drawSelectionInRect(dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .None{
            let selectionRect = NSInsetRect(self.bounds, 0.5, 0.5)
            NSColor.selectedMenuItemColor().setStroke()
            NSColor.selectedMenuItemColor().setFill()
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0.0, yRadius: 0.0)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
    
    override var interiorBackgroundStyle:NSBackgroundStyle{
        get{
            if self.selected {
                return NSBackgroundStyle.Dark
            }
            else{
                return NSBackgroundStyle.Light
            }
        }
    }
}

class AutoCompleteTextField:NSTextField{
    weak var tableViewDelegate:AutoCompleteTableViewDelegate?
    var popOverWidth:NSNumber = 110
    let popOverPadding:CGFloat = 0.0
    let maxResults = 10
    
    var autoCompletePopover:NSPopover?
    weak var autoCompleteTableView:NSTableView?
    var matches:[String]?
    
    override func awakeFromNib() {
        let column1 = NSTableColumn(identifier: "text")
        column1.editable = false
        column1.width = CGFloat(popOverWidth.floatValue) - 2 * popOverPadding
        
        let tableView = NSTableView(frame: NSZeroRect)
        tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.Regular
        tableView.backgroundColor = NSColor.clearColor()
        tableView.rowSizeStyle = NSTableViewRowSizeStyle.Small
        tableView.intercellSpacing = NSMakeSize(10.0, 0.0)
        tableView.headerView = nil
        tableView.refusesFirstResponder = true
        tableView.target = self
        tableView.doubleAction = #selector(AutoCompleteTextField.insert(_:))
        tableView.addTableColumn(column1)
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        self.autoCompleteTableView = tableView
        
        let tableSrollView = NSScrollView(frame: NSZeroRect)
        tableSrollView.drawsBackground = false
        tableSrollView.documentView = tableView
        tableSrollView.hasVerticalScroller = true
        
        let contentView:NSView = NSView(frame: NSZeroRect)
        contentView.addSubview(tableSrollView)
        
        let contentViewController = NSViewController()
        contentViewController.view = contentView
        
        self.autoCompletePopover = NSPopover()
        self.autoCompletePopover?.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        self.autoCompletePopover?.animates = false
        self.autoCompletePopover?.contentViewController = contentViewController
        
        self.matches = [String]()
    }
    
    override func keyUp(theEvent: NSEvent) {
        let row:Int = self.autoCompleteTableView!.selectedRow
        let isShow = self.autoCompletePopover!.shown
        switch(theEvent.keyCode){
        case 53: //Esc
            if let isShow = self.autoCompletePopover?.shown{
                if isShow{
                    self.autoCompletePopover?.close()
                }
            }
            return //skip default behavior
            
        case 125: //Down
            if isShow{
                self.autoCompleteTableView?.selectRowIndexes(NSIndexSet(index: row + 1), byExtendingSelection: false)
                self.autoCompleteTableView?.scrollRowToVisible((self.autoCompleteTableView?.selectedRow)!)
                return //skip default behavior
            }
            break
            
        case 126: //Up
            if isShow{
                self.autoCompleteTableView?.selectRowIndexes(NSIndexSet(index: row - 1), byExtendingSelection: false)
                self.autoCompleteTableView?.scrollRowToVisible((self.autoCompleteTableView?.selectedRow)!)
                return //skip default behavior
            }
            break
        
        case 36: // Return
            if isShow{
                self.insert(self)
                return //skip default behavior
            }
            
        case 48: //Tab
            return
        
        case 49: //Space
            if isShow {
                self.autoCompletePopover?.close()
            }
            break
            
        default:
            break
        }
        
        super.keyUp(theEvent)
        self.complete(self)
    }

    func insert(sender:AnyObject){
        let selectedRow = self.autoCompleteTableView!.selectedRow
        let matchCount = self.matches!.count
        if selectedRow >= 0 && selectedRow < matchCount{
            self.stringValue = self.matches![selectedRow]
            if self.tableViewDelegate!.respondsToSelector(#selector(AutoCompleteTableViewDelegate.didSelectItem(_:))){
                self.tableViewDelegate!.didSelectItem!(self.stringValue)
            }
        }
        self.autoCompletePopover?.close()
    }
    
    override func complete(sender: AnyObject?) {
        let lengthOfWord = self.stringValue.characters.count
        let subStringRange = NSMakeRange(0, lengthOfWord)
        
        //This happens when we just started a new word or if we have already typed the entire word
        if subStringRange.length == 0 || lengthOfWord == 0 {
            Swift.print("complete lengthOfWord = \(lengthOfWord) identier = \((sender as! NSTextField).identifier)")
            self.autoCompletePopover?.close()
            return
        }
        
        let index = 0
        self.matches = self.completionsForPartialWordRange(subStringRange, indexOfSelectedItem: index)
        
        if self.matches!.count > 0 {
            self.autoCompleteTableView?.reloadData()
            self.autoCompleteTableView?.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            self.autoCompleteTableView?.scrollRowToVisible(index)
            
            let numberOfRows = min(self.autoCompleteTableView!.numberOfRows, maxResults)
            let height = (self.autoCompleteTableView!.rowHeight + self.autoCompleteTableView!.intercellSpacing.height) * CGFloat(numberOfRows) + 2 * 0.0
            let frame = NSMakeRect(0, 0, CGFloat(popOverWidth.floatValue), height)
            self.autoCompleteTableView?.enclosingScrollView?.frame = NSInsetRect(frame, popOverPadding, popOverPadding)
            self.autoCompletePopover?.contentSize = NSMakeSize(NSWidth(frame), NSHeight(frame))
            
            let rect = self.visibleRect
            self.autoCompletePopover?.showRelativeToRect(rect, ofView: self, preferredEdge: NSRectEdge.MaxY)
        }
        else{
            self.autoCompletePopover?.close()
        }
    }
    
    func completionsForPartialWordRange(charRange: NSRange, indexOfSelectedItem index: Int) ->[String]{
        if self.tableViewDelegate!.respondsToSelector(#selector(AutoCompleteTableViewDelegate.textField(_:completions:forPartialWordRange:indexOfSelectedItem:))){
            return self.tableViewDelegate!.textField(self, completions: [], forPartialWordRange: charRange, indexOfSelectedItem: index)
        }
        return []
    }
}

// MARK: - NSTableViewDelegate
extension AutoCompleteTextField:NSTableViewDelegate{
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView = tableView.makeViewWithIdentifier("MyView", owner: self) as? NSTableCellView
        if cellView == nil{
            cellView = NSTableCellView(frame: NSZeroRect)
            let textField = NSTextField(frame: NSZeroRect)
            textField.bezeled = false
            textField.drawsBackground = false
            textField.editable = false
            textField.selectable = false
            cellView!.addSubview(textField)
            cellView!.textField = textField
            cellView!.identifier = "MyView"
        }
        let attrs = [NSForegroundColorAttributeName:NSColor.blackColor(),NSFontAttributeName:NSFont.systemFontOfSize(13)]
        let mutableAttriStr = NSMutableAttributedString(string: self.matches![row], attributes: attrs)
        cellView!.textField!.attributedStringValue = mutableAttriStr
        
        return cellView
    }
}

// MARK: - NSTableViewDataSource
extension AutoCompleteTextField:NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if self.matches == nil{
            return 0
        }
        return self.matches!.count
    }
}