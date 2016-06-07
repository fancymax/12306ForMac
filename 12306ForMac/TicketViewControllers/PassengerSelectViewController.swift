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
    var hasSelectedPassengerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hasSelectedPassengerCount = 0
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
    
    @IBAction func checkPassenger(sender:NSButton){
        if sender.state == NSOnState{
            hasSelectedPassengerCount += 1
        }
        else{
            hasSelectedPassengerCount -= 1
        }
        
        if hasSelectedPassengerCount > maxSelectedPassengerCount {
            hasSelectedPassengerCount -= 1
            sender.state = NSOffState
            
            for passenger in passengers{
                if passenger.passenger_name == sender.title {
                    passenger.isChecked = false
                    break
                }
            }
            //todo 提示乘客超过5个
            return
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(DidSendCheckPassengerMessageNotification, object: sender.title)
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
}