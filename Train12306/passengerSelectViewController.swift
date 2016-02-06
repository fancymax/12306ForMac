//
//  PassengerSelectViewController.swift
//  
//
//  Created by fancymax on 15/10/7.
//
//

import Cocoa

class PassengerSelectViewController: NSViewController,NSTableViewDataSource{

    @IBOutlet weak var passengerTable: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
    
    func reloadPassenger(){
        self.passengerTable.reloadData()
    }
}