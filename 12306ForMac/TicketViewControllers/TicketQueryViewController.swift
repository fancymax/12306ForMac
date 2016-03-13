//
//  TicketQueryMainViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/13.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TicketQueryViewController: NSViewController {
    @IBOutlet weak var stackContentView: NSStackView!

    var normalSearchViewController: NormalSearchViewController?
    var ticketTableViewController: TicketTableViewController?
    var disclosureViewController: DisclosureViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.normalSearchViewController = NormalSearchViewController(nibName: "NormalSearchViewController",bundle: nil)
        self.ticketTableViewController = TicketTableViewController(nibName: "TicketTableViewController",bundle: nil)
        self.normalSearchViewController?.ticketTableDelegate = self.ticketTableViewController
        self.disclosureViewController = DisclosureViewController(nibName:"DisclosureViewController", bundle:nil)
        
        self.stackContentView.addView(normalSearchViewController!.view, inGravity:.Top)
        self.stackContentView.addView(disclosureViewController!.view, inGravity: .Top)
        self.stackContentView.addView(ticketTableViewController!.view, inGravity: .Top)
        
        self.stackContentView.orientation = .Vertical
        self.stackContentView.alignment = .CenterX
        self.stackContentView.spacing = 0
    }
    
}
