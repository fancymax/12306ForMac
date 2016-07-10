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
    @IBOutlet weak var tips: FlashLabel!
    
    var service = Service()
    var ticketQueryResult = [QueryLeftNewDTO]()
    var date:String?
    
    lazy var submitWindowController:SubmitWindowController = SubmitWindowController()
    var loadingTipController = LoadingTipViewController(nibName:"LoadingTipViewController",bundle: nil)!
    
    lazy var trainCodeDetailViewController:TrainCodeDetailViewController = TrainCodeDetailViewController()
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.trainCodeDetailViewController
        return popover
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TicketTableViewController.receiveDidSendSubmitMessageNotification(_:)), name: DidSendSubmitMessageNotification, object: nil)
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
    }
    
    func receiveDidSendSubmitMessageNotification(note: NSNotification){
        print("receiveDidSendSubmitMessageNotification")
        submitWindowController = SubmitWindowController()
        if let window = self.view.window {
            window.beginSheet(submitWindowController.window!, completionHandler:
                {response in
                if response == NSModalResponseOK{
                    ///
                }
            })
        }
    }
    
    func queryLeftTicket(fromStationCode: String, toStationCode: String, date: String) {
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            self.ticketQueryResult = tickets
            self.leftTicketTable.reloadData()
            self.loadingTipController.stop()
        }
        
        let failureHandler = {(error:NSError)->() in
            self.loadingTipController.stop()
            self.tips.show(translate(error), forDuration: 1, withFlash: false)
        }
        
        self.ticketQueryResult = [QueryLeftNewDTO]()
        self.leftTicketTable.reloadData()
        
        self.loadingTipController.start(tip:"正在查询...")
//        self.fromStationCode = fromStationCode
//        self.toStationCode = toStationCode
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
    
    func setSeatCodeForSelectedPassenger(trainCode:String, seatCodeName:String){
        for passenger in MainModel.selectPassengers{
            passenger.seatCodeName = seatCodeName
            passenger.seatCode = MainModel.getSeatCodeBy(seatCodeName,trainCode: trainCode)
        }
    }
    
    @IBAction func submit(sender: NSButton){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
//        notificationCenter.postNotificationName(DidSendSubmitMessageNotification, object: nil)
//        return
        
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
        
        self.loadingTipController.start(tip:"正在提交...")
        
        let postSubmitWindowMessage = {
            self.loadingTipController.stop()
            self.tips.show("提交成功", forDuration: 0.1, withFlash: false)
            //post submit notification
            notificationCenter.postNotificationName(DidSendSubmitMessageNotification, object: nil)
        }
        
        let failHandler = {(error:NSError)->() in
            self.loadingTipController.stop()
            
            if error.code == ServiceError.Code.CheckUserFailed.rawValue {
                notificationCenter.postNotificationName(DidSendLoginMessageNotification, object: nil)
            }else{
                self.tips.show(translate(error), forDuration: 0.1, withFlash: false)
            }
        }
        
        service.submitFlow(success: postSubmitWindowMessage, failure: failHandler)
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
    func saveSelectedPassenger(){
        //获取当前用户
        
        //更新选择的乘客
        
        //保存
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
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return tableView.makeViewWithIdentifier("row", owner: tableView) as? NSTableRowView
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let columnIdentifier = tableColumn!.identifier
        if(columnIdentifier == "余票信息"){
            let cell = view as! TrainInfoTableCellView
            cell.ticketInfo = ticketQueryResult[row]
            cell.setTarget(self, action: #selector(TicketTableViewController.submit(_:)))
        }
        else if(columnIdentifier == "发站" || columnIdentifier == "到站"){
            let cell = view as! TrainTableCellView
            cell.ticketInfo = ticketQueryResult[row]
        }
        else if(columnIdentifier == "车次"){
            let cell = view as! TrainCodeTableCellView
            cell.setClickableTextFieldDelegate(self)
        }
        
        return view
    }
    
}

// MARK: - ClickableTextFieldDelegate
extension TicketTableViewController: ClickableTextFieldDelegate {
    func textFieldDidMouseEntered(sender:ClickableTextField) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxX
        popover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
        
        let trainCode = sender.stringValue
        var queryByTrainCodeParam = QueryByTrainCodeParam()
        queryByTrainCodeParam.depart_date = self.date!
        
        for i in 0..<ticketQueryResult.count {
            if ticketQueryResult[i].TrainCode == trainCode {
                queryByTrainCodeParam.train_no = ticketQueryResult[i].train_no!
                queryByTrainCodeParam.from_station_telecode = ticketQueryResult[i].FromStationCode!
                queryByTrainCodeParam.to_station_telecode = ticketQueryResult[i].ToStationCode!
                break
            }
        }
        
        self.trainCodeDetailViewController.queryByTrainCodeParam = queryByTrainCodeParam
    }
    
    
    func textFieldDidMouseExited(sender: ClickableTextField) {
        print("textField Exited")
    }
}
