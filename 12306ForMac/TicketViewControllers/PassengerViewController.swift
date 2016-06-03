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
    
    @IBOutlet weak var passengerCheckBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passengerCheckBox.title = passenger!.passenger_name!
    }
    
    @IBAction func unSelectPassenger(sender: NSButton) {
        passenger?.isChecked = false
        sender.state = NSOnState
        self.view.hidden = true
    }
    
    func select(){
        if passenger!.isChecked {
            self.view.hidden = false
        }
        else{
            self.view.hidden = true
        }
    }
    
    func check() {
        self.view.hidden = false
    }
    
    func unCheck() {
        self.view.hidden = true
    }
}
