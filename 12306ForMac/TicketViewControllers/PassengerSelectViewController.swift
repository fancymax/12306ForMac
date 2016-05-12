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
    var passengers = [PassengerDTO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadPassenger(passengersToShow:[PassengerDTO]){
        self.passengers = passengersToShow
        self.passengerTable.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.passengers.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return self.passengers[row]
    }
    
    func checkPassenger(sender:NSButton){
        print("checkPassenger")
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(DidSendCheckPassengerMessageNotification, object: sender.title)
        
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        let check = cellView.viewWithTag(1) as! NSButton
        check.target = self
        check.action = #selector(PassengerSelectViewController.checkPassenger(_:))
        
        return cellView
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
}