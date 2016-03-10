//
//  DisclosureViewController.swift
//  Train12306
//
//  Created by fancymax on 15/9/28.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

class DisclosureViewController: NSViewController,NSPopoverDelegate{
    @IBOutlet weak var passengersView: NSStackView!
    
    var passengerViewControllerList = [PassengerViewController]()
    let passengerSelectViewController = PassengerSelectViewController()

    @IBAction func selectPassenger(sender: NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxY
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
       
//        initPassenger()
        passengerSelectViewController.reloadPassenger()
    }
    
    func initPassenger(){
        MainModel.passengers.append(PassengerDTO())
        MainModel.passengers.append(PassengerDTO())
    }
    
    func popoverDidClose(notification: NSNotification) {
        for i in 0..<MainModel.passengers.count{
            if(MainModel.passengers[i].isChecked){
                if passengerSelected(MainModel.passengers[i]){
                    checkPassenger(MainModel.passengers[i])
                }
                else{
                    let p = PassengerViewController()
                    p.passenger = MainModel.passengers[i]
                    passengerViewControllerList.append(p)
                    self.passengersView.addView(p.view, inGravity:.Top)
                }
            }
            else{
                checkPassenger(MainModel.passengers[i])
            }
        }
    }
    
    func passengerSelected(passenger:PassengerDTO) -> Bool{
        for controller in passengerViewControllerList where controller.passenger == passenger{
            return true
        }
        return false
    }
    
    func checkPassenger(passenger:PassengerDTO){
        for controller in passengerViewControllerList where controller.passenger == passenger{
            controller.SelectPassenger()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passengerViewControllerList = [PassengerViewController]()
    }
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.passengerSelectViewController
        popover.delegate = self
        return popover
        }()
}
