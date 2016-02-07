//
//  DisclosureViewController.swift
//  Train12306
//
//  Created by fancymax on 15/9/28.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

class DisclosureViewController: NSViewController,NSPopoverDelegate{
    
    var passengerViewControllerList = [PassengerViewController]()
    let passengerSelectViewController = PassengerSelectViewController()

    @IBAction func selectPassenger(sender: NSButton) {
        
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxY
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
        
        passengerSelectViewController.reloadPassenger()
    }
    
    func popoverDidClose(notification: NSNotification) {
        for i in 0..<MainModel.passengers.count{
            if(MainModel.passengers[i].isChecked){
                if isPassengerHasSelected(MainModel.passengers[i]){
                    checkPassenger(MainModel.passengers[i])
                }
                else{
                    let test = PassengerViewController()
                    test.passenger = MainModel.passengers[i]
                    passengerViewControllerList.append(test)
                    self.passengersView.addView(test.view, inGravity:.Top)
                }
            }
            else{
                checkPassenger(MainModel.passengers[i])
            }
        }
    }
    
    func isPassengerHasSelected(passenger:PassengerDTO) -> Bool{
        for passengerViewController in passengerViewControllerList{
            if(passengerViewController.passenger == passenger){
                return true
                
            }
        }
        return false
    }
    
    func checkPassenger(passenger:PassengerDTO){
        for passengerViewController in passengerViewControllerList{
            if(passengerViewController.passenger == passenger){
                passengerViewController.SelectPassenger()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        constrain.constant = 0
        _disclosureIsClosed = true
        
        passengerViewControllerList = [PassengerViewController]()
    }
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.passengerSelectViewController
        popover.delegate = self
        return popover
        }()
    
    @IBOutlet weak var passengersView: NSStackView!
    @IBOutlet weak var constrain: NSLayoutConstraint!
    @IBAction func toggleDisclosure(sender:AnyObject){
        if(!_disclosureIsClosed){
            constrain.constant = 0
            _disclosureIsClosed = true
        }
        else{
            constrain.constant = 40
            _disclosureIsClosed = false
        }
    } 
    
    private var _disclosureIsClosed = false
    private var closingConstraint:NSLayoutConstraint?
}
