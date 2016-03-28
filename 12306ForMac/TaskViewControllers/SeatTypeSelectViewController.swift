//
//  TicketTypeSelectViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/28.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class SeatTypeSelectViewController: NSViewController {
    
    @IBOutlet weak var seatTypeTable: NSTableView!
    var seatTypes = [SeatTypeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadTicketTypes(ticketTypesToShow:[SeatTypeModel]){
        self.seatTypes = ticketTypesToShow
        self.seatTypeTable.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.seatTypes.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return self.seatTypes[row]
    }
    
    func checkTicketType(sender:NSButton){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(DidSendCheckSeatTypeMessageNotification, object: sender.title)
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        let check = cellView.viewWithTag(1) as! NSButton
        check.target = self
        check.action = Selector("checkTicketType:")
        
        return cellView
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
}
