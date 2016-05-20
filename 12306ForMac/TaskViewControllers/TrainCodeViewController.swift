//
//  TrainCodeViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/5/21.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainCodeViewController: NSViewController {
    
    var ticket: QueryLeftNewDTO!
    @IBOutlet weak var checkBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkBox.title = ticket.TrainCode!
    }
    
    @IBAction func unSelect(sender: NSButton) {
        ticket.isSelected = false
        sender.state = NSOnState
        self.view.hidden = true
    }
    
    func select(){
        if ticket.isSelected {
            self.view.hidden = false
        }
        else{
            self.view.hidden = true
        }
    }

}
