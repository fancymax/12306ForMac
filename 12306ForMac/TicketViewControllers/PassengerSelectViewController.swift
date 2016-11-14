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
    }
    
    func reloadPassenger(_ passengersToShow:[PassengerDTO]){
        self.passengers = passengersToShow
        self.passengerTable.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.passengers.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.passengers[row]
    }
    
    @IBAction func checkPassenger(_ sender:NSButton){
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
        
        let row = passengerTable.row(for: sender)
        NotificationCenter.default.post(name: Notification.Name.App.DidCheckPassenger, object: passengers[row].passenger_id_no)
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
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}
