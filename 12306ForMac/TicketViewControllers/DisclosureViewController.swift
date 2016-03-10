//
//  DisclosureViewController.swift
//  Train12306
//
//  Created by fancymax on 15/9/28.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

class DisclosureViewController: NSViewController{
    @IBOutlet weak var passengersView: NSStackView!
    
    var passengerViewControllerList = [PassengerViewController]()
    let passengerSelectViewController = PassengerSelectViewController()
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.passengerSelectViewController
        return popover
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passengerViewControllerList = [PassengerViewController]()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("receiveDidSendCheckPassengerMessageNotification:"), name: DidSendCheckPassengerMessageNotification, object: nil)
    }
    
    func receiveDidSendCheckPassengerMessageNotification(notification: NSNotification) {
        let name = notification.object as! String
        
        for i in 0..<MainModel.passengers.count {
            if MainModel.passengers[i].passenger_name == name{
                if passengerSelected(MainModel.passengers[i]){
                    checkPassenger(MainModel.passengers[i])
                }
                else{
                    let p = PassengerViewController()
                    p.passenger = MainModel.passengers[i]
                    passengerViewControllerList.append(p)
                    self.passengersView.addView(p.view, inGravity:.Top)
                }
                
                break
            }
            
        }
        
    }

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
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
}
