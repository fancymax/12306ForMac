//
//  PassengerSelectViewController.swift
//  
//
//  Created by fancymax on 15/10/7.
//
//

import Cocoa

class PassengerSelectViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate{

    @IBOutlet weak var passengerTable: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadPassenger(){
        self.passengerTable.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return MainModel.passengers.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if(MainModel.passengers.count - 1 >= row)
        {
            return MainModel.passengers[row]
        }
        else
        {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        let name = cellView.viewWithTag(0) as! NSTextField
        name.drawsBackground = true
        name.backgroundColor = NSColor.clearColor()
        let attrs = [NSForegroundColorAttributeName:NSColor.blackColor(),NSFontAttributeName:NSFont.systemFontSize()]
        let mutableAttriStr = NSMutableAttributedString(string: MainModel.passengers[row].passenger_name!, attributes: attrs)
        name.attributedStringValue = mutableAttriStr
        
        return cellView
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
}