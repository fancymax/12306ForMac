//
//  TicketTableViewController.swift
//  Train12306
//
//  Created by fancymax on 15/9/29.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

protocol TicketTableDelegate{
    func queryLeftTicket(fromStationCode:String, toStationCode:String, date:String)
}

class TicketTableViewController: NSViewController,TicketTableDelegate{
    
    @IBOutlet weak var leftTicketTable: NSTableView!
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingTip: NSTextField!
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    @IBOutlet weak var tips: FlashLabel!
    
    var service = Service()
    var ticketQueryResult = [QueryLeftNewDTO]()
    var hasAddSubmitObserver:Bool = false
    var toStationCode:String?
    var fromStationCode:String?
    var date:String?
    
    var submitWindowController = PreOrderWindowController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.hidden = true
        
        if !hasAddSubmitObserver{
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: Selector("receiveDidSendSubmitMessageNotification:"), name: DidSendSubmitMessageNotification, object: nil)
        }
    }
    
    func receiveDidSendSubmitMessageNotification(note: NSNotification){
        print("receiveDidSendSubmitMessageNotification")
        submitWindowController = PreOrderWindowController()
        if let window = self.view.window {
            window.beginSheet(submitWindowController.window!, completionHandler:
                {response in
                if response == NSModalResponseOK{
                    ///
                }
            })
        }
    }
    
    func startLoadingTip(tip:String) 
    {
        loadingSpinner.startAnimation(nil)
        loadingTip.stringValue = tip
        loadingView.hidden = false
    }
    
    func stopLoadingTip(){
        loadingSpinner.stopAnimation(nil)
        loadingView.hidden = true
    }
    
    func queryLeftTicket(fromStationCode: String, toStationCode: String, date: String) {
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            self.ticketQueryResult = tickets
            self.leftTicketTable.reloadData()
            
            self.stopLoadingTip()
        }
        
        let failureHandler = {(error:NSError)->() in
            self.stopLoadingTip()
            
            self.tips.show(translate(error), forDuration: 1, withFlash: false)
        }
        
        self.startLoadingTip("正在查询...")
        self.fromStationCode = fromStationCode
        self.toStationCode = toStationCode
        self.date = date
        
        var params = LeftTicketParam()
        params.from_stationCode = fromStationCode
        params.to_stationCode = toStationCode
        
        params.train_date = date
        params.purpose_codes = "ADULT"
        
        service.queryTicketFlowWith(params, success: successHandler,failure: failureHandler)
    }
    
    func setSelectedPassenger(){
        MainModel.selectPassengers = [PassengerDTO]()
        
        for i in 0..<MainModel.passengers.count{
            let p = MainModel.passengers[i]
            if (p.isChecked && !MainModel.selectPassengers.contains(p)){
                MainModel.selectPassengers.append(p)
            }
        }
    }
    
    func setSeatCodeForSelectedPassenger(seatCode:String, seatCodeName:String){
        for passenger in MainModel.selectPassengers{
            passenger.seatCodeName = seatCodeName
            passenger.seatCode = MainModel.getSeatCodeBy(seatCodeName,trainCode: seatCode)
        }
    }
    
    func submit(sender: NSButton){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        if !MainModel.isGetUserInfo {
            notificationCenter.postNotificationName(DidSendLoginMessageNotification, object: nil)
            return
        }
        
        setSelectedPassenger()
        
        if MainModel.selectPassengers.count == 0 {
            tips.show("请先选择乘客", forDuration: 0.1, withFlash: false)
            return
        }
        
        let selectedRow = leftTicketTable.rowForView(sender)
        MainModel.selectedTicket = ticketQueryResult[selectedRow]
        setSeatCodeForSelectedPassenger(MainModel.selectedTicket!.TrainCode! ,seatCodeName: sender.identifier!)
        
        self.startLoadingTip("正在提交...")
        
        let postSubmitWindowMessage = {
            self.stopLoadingTip()
            self.tips.show("提交成功", forDuration: 0.1, withFlash: false)
            //post submit notification
            notificationCenter.postNotificationName(DidSendSubmitMessageNotification, object: nil)
        }
        
        let failHandler = {(error:NSError)->() in
            self.stopLoadingTip()
            if error.domain == "checkUser"{
                notificationCenter.postNotificationName(DidSendLoginMessageNotification, object: nil)
            }else{
                //print submit error
                if error.code != 0 {
                    self.tips.show(error.domain, forDuration: 0.1, withFlash: false)
                }
            }
        }
        
        service.submitFlow(success: postSubmitWindowMessage, failure: failHandler)
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
}

// MARK: - NSTableViewDataSource 
extension TicketTableViewController: NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return ticketQueryResult.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if(ticketQueryResult.count - 1 >= row)
        {
            return ticketQueryResult[row]
        }
        else
        {
            return nil
        }
    }
}

// MARK: - NSTableViewDelegate
extension TicketTableViewController: NSTableViewDelegate{
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
        let ticketRow = ticketQueryResult[row]
        
        if(tableColumn!.identifier == "余票信息"){
            
            let sub1:NSButton = view.viewWithTag(1) as! NSButton
            let sub2:NSButton = view.viewWithTag(2) as! NSButton
            let sub3:NSButton = view.viewWithTag(3) as! NSButton
            let sub4:NSButton = view.viewWithTag(4) as! NSButton
            let sub5:NSButton = view.viewWithTag(5) as! NSButton
            let sub6:NSButton = view.viewWithTag(6) as! NSButton
            let sub7:NSButton = view.viewWithTag(7) as! NSButton
            let sub8:NSButton = view.viewWithTag(8) as! NSButton
            let sub9:NSButton = view.viewWithTag(9) as! NSButton
            let sub10:NSButton = view.viewWithTag(10) as! NSButton
            
            let label:NSTextField = view.viewWithTag(11) as! NSTextField
            
            func setTicketButton(ticket:String,sender:NSButton){
                if ((ticket == "--")||(ticket == "无")||(ticket == "*")){
                    sender.hidden = true
                }
                else if (ticket == "有"){
                    sender.target = self
                    sender.action = Selector("submit:")
                    sender.hidden = false
                    sender.enabled = true
                    sender.title = sender.alternateTitle + "(有票)"
                }
                else{
                    sender.target = self
                    sender.action = Selector("submit:")
                    sender.hidden = false
                    sender.enabled = true
                    sender.title = sender.alternateTitle + "(\(ticket)张)"
                }
            }
            
            setTicketButton(ticketRow.Swz_Nu!, sender: sub1)
            setTicketButton(ticketRow.Tz_Num!, sender: sub2)
            setTicketButton(ticketRow.Zy_Num!, sender: sub3)
            setTicketButton(ticketRow.Ze_Num!, sender: sub4)
            setTicketButton(ticketRow.Gr_Num!, sender: sub5)
            setTicketButton(ticketRow.Rw_Num!, sender: sub6)
            setTicketButton(ticketRow.Yw_Num!, sender: sub7)
            setTicketButton(ticketRow.Rz_Num!, sender: sub8)
            setTicketButton(ticketRow.Yz_Num!, sender: sub9)
            setTicketButton(ticketRow.Wz_Num!, sender: sub10)
            
            if ticketRow.canWebBuy == "Y" {
                label.hidden = true
            }
            else if ticketRow.canWebBuy == "N" {

                label.stringValue = "本车次暂无可售车票"
                label.hidden = false
            }
            else if ticketRow.canWebBuy == "IS_TIME_NOT_BUY"{
                if ticketRow.buttonTextInfo == "23:00-07:00系统维护时间" {
                    sub1.enabled = false
                    sub2.enabled = false
                    sub3.enabled = false
                    sub4.enabled = false
                    sub5.enabled = false
                    sub6.enabled = false
                    sub7.enabled = false
                    sub8.enabled = false
                    sub9.enabled = false
                    sub10.enabled = false
                    label.hidden = true
                }
                else
                {
                    if let range = ticketRow.buttonTextInfo!.rangeOfString("<br/>"){
                        ticketRow.buttonTextInfo!.removeRange(range)
                    }
                    label.stringValue = ticketRow.buttonTextInfo!
                    label.hidden = false
                    return view
                }
            }
            
            if sub1.hidden && sub2.hidden && sub3.hidden && sub4.hidden && sub5.hidden && sub6.hidden && sub7.hidden && sub8.hidden && sub9.hidden && sub10.hidden {
                label.stringValue = "本车次暂无可售车票"
                label.hidden = false
            }
        
        }
        else if(tableColumn!.identifier == "发站"){
            let startStation:NSTextField = view.viewWithTag(1) as! NSTextField
            let startMark:NSTextField = view.viewWithTag(11) as! NSTextField
            let startTime:NSTextField = view.viewWithTag(3) as! NSTextField
            startStation.stringValue = ticketRow.FromStationName!
            startTime.stringValue = ticketRow.start_time!
            if ticketRow.isStartStation{
                startMark.hidden = false
            }
            else{
                startMark.hidden = true
            }
        }
        else if(tableColumn!.identifier == "到站"){
            let endStation:NSTextField = view.viewWithTag(1) as! NSTextField
            let endMark:NSTextField = view.viewWithTag(11) as! NSTextField
            let endTime:NSTextField = view.viewWithTag(3) as! NSTextField
            endStation.stringValue = ticketRow.ToStationName!
            endTime.stringValue = ticketRow.arrive_time!
            if ticketRow.isEndStation{
                endMark.hidden = false
            }
            else{
                endMark.hidden = true
            }
        }
        
        return view
    }
    
}
