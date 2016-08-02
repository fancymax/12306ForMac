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
    let maxSelectedPassengerCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(PassengerSelectViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
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
    
    func receiveLogoutMessageNotification(notification: NSNotification) {
        passengers.removeAll()
        passengerTable.reloadData()
    }
    
    @IBAction func checkPassenger(sender:NSButton){
        if isMaxPassengerNumber(exclude:sender.title) {
            sender.state = NSOffState
            
            for passenger in passengers{
                if passenger.passenger_name == sender.title {
                    passenger.isChecked = false
                    break
                }
            }
            
            return
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(DidSendCheckPassengerMessageNotification, object: sender.title)
    }
    
    func isMaxPassengerNumber(exclude excludePassenger:String)->Bool {
        var count = 0
        for passenger in passengers{
            if (passenger.isChecked)&&(passenger.passenger_name != excludePassenger) {
                count += 1
            }
        }
        
        if count >= maxSelectedPassengerCount {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
}