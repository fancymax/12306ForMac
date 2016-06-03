//
//  TicketTypeViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/28.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class SeatTypeViewController: NSViewController {

    var seatType:SeatTypeModel!
    
    @IBOutlet weak var passengerCheckBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        passengerCheckBox.title = seatType.name
    }
    
    @IBAction func unSelect(sender: NSButton) {
        seatType.isChecked = false
        sender.state = NSOnState
        self.view.hidden = true
    }
    
    func select(){
        self.view.hidden = false
    }
    
    func unSelect(){
        self.view.hidden = true
    }
}
