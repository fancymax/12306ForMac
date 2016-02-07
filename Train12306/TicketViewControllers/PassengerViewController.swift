//
//  HorizontalListObjectViewController.swift
//  
//
//  Created by fancymax on 15/10/5.
//
//

import Cocoa

class PassengerViewController: NSViewController {
    
    var passenger:PassengerDTO?
    
    @IBOutlet private weak var passengerNameLabel: NSTextField!
    
    @IBOutlet weak var passengerCheckBox: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        passengerNameLabel.stringValue = passenger!.passenger_name!
    }
    @IBAction func unSelectPassenger(sender: NSButton) {
        passenger?.isChecked = false
        sender.state = NSOnState
        self.view.hidden = true
        //保持check状态
    }
    
    func SelectPassenger(){
        if passenger!.isChecked {
            self.view.hidden = false
        }
        else{
            self.view.hidden = true
        }
    }
    

    
}
