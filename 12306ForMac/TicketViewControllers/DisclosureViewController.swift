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
    
    @IBOutlet weak var filterBtn: LoginButton!
    @IBOutlet weak var filterCbx: NSButton!
    
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
        filterBtn.enabled = false
        filterCbx.enabled = false
        
        notificationCenter.addObserver(self, selector: #selector(DisclosureViewController.receiveCheckPassengerMessageNotification(_:)), name: DidSendCheckPassengerMessageNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(DisclosureViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(DisclosureViewController.receiveCanFilterNotification(_:)), name: CanFilterTrainNotification, object: nil)
    }
    
    func receiveCheckPassengerMessageNotification(notification: NSNotification) {
        if !self.popover.shown {
            print("not my message in DisclosureViewController")
            return
        }
        
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
    
    func receiveLogoutMessageNotification(notification: NSNotification) {
        passengerViewControllerList.removeAll()
        for view in passengersView.views{
            view.removeFromSuperview()
        }
    }
    
    func receiveCanFilterNotification(notification: NSNotification) {
        let canFilter = notification.object as! Bool
        if canFilter {
            filterBtn.enabled = true
            filterCbx.enabled = true
        }
        else {
            filterBtn.enabled = false
            filterCbx.enabled = false
            
        }
    }
    
    @IBAction func clickTrainFilterBtn(sender: AnyObject) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(DidSendTrainFilterMessageNotification, object: sender.title)
    }
    

    @IBAction func selectPassenger(sender: NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxY
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
       
//        initPassenger()
        passengerSelectViewController.reloadPassenger(MainModel.passengers)
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
            controller.select()
        }
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
}
