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
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    @IBOutlet weak var tips: FlashLabel!
    
    var service = Service()
    var ticketQueryResult = [QueryLeftNewDTO]()
    var toStationCode:String?
    var fromStationCode:String?
    var date:String?
    
    var submitWindowController = PreOrderWindowController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.hidden = true
    }
    
    func startQueryTip()
    {
        loadingSpinner.startAnimation(nil)
        loadingView.hidden = false
    }
    
    func stopQueryTip(){
        loadingSpinner.stopAnimation(nil)
        loadingView.hidden = true
    }
    
    func queryLeftTicket(fromStationCode: String, toStationCode: String, date: String) {
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            //如果成功 则从MainModel里获取数据
            self.ticketQueryResult = tickets
            self.leftTicketTable.reloadData()
            
            //停止提示信息旋转
            self.stopQueryTip()
        }
        
        let failureHandler = {
            //停止提示信息旋转
            self.stopQueryTip()
            //失败信息提示
            
        }
        
        startQueryTip()
        self.fromStationCode = fromStationCode
        self.toStationCode = toStationCode
        self.date = date
        
        var params = LeftTicketParam()
        params.from_station = fromStationCode
        params.to_station = toStationCode
        params.train_date = date
        params.purpose_codes = "ADULT"
        
        service.queryTicketFlowWith(params, success: successHandler,failure: failureHandler)
    }
    
    func setSelectPassenger(){
        MainModel.selectPassengers = [PassengerDTO]()
        
        for i in 0..<MainModel.passengers.count{
            let p = MainModel.passengers[i]
            if (p.isChecked && !MainModel.selectPassengers.contains(p)){
                MainModel.selectPassengers.append(p)
            }
        }
    }
    
    func submit(sender: NSButton){
        if !MainModel.isGetUserInfo {
            tips.show("请先登录～", forDuration: 0.1, withFlash: false)
            return
        }
        
        setSelectPassenger()
        
        if MainModel.selectPassengers.count == 0 {
            tips.show("请先选择乘客～", forDuration: 0.1, withFlash: false)
            return
        }
        
        
        submitWindowController = PreOrderWindowController()
        
        let selectedRow = leftTicketTable.rowForView(sender)
        MainModel.selectedTicket = ticketQueryResult[selectedRow]
        let seatCodeName = sender.identifier!
        let trainCode = MainModel.selectedTicket!.TrainCode!
        
        print(MainModel.seatTypeNameDic[seatCodeName])
        
        for passenger in MainModel.selectPassengers{
            passenger.seatCodeName = seatCodeName
            passenger.seatCode = MainModel.getSeatCodeBy(seatCodeName,trainCode: trainCode)
        }
        
        submitWindowController.trainInfo = ticketQueryResult[selectedRow]
        if let window = self.view.window {
            window.beginSheet(submitWindowController.window!, completionHandler:
                {response in
                if response == NSModalResponseOK{
                    ///
                }
            })
        }
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
