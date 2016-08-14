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

    @IBOutlet var firstSearchView: NSView!
    @IBOutlet var secondSearchView: NSView!
    @IBOutlet var ticketTableView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackContentView.addView(firstSearchView, inGravity:.Top)
        self.stackContentView.addView(secondSearchView, inGravity: .Top)
        self.stackContentView.addView(ticketTableView, inGravity: .Top)
        
        self.stackContentView.orientation = .Vertical
        self.stackContentView.alignment = .CenterX
        self.stackContentView.spacing = 0
        
        self.fromStationName.tableViewDelegate = self
        self.toStationName.tableViewDelegate = self
        
        self.fromStationName.stringValue = QueryDefaultManager.sharedInstance.lastFromStation
        self.toStationName.stringValue = QueryDefaultManager.sharedInstance.lastToStation
        
        if QueryDefaultManager.sharedInstance.lastQueryDate.compare(NSDate()) == .OrderedAscending {
            self.queryDate.dateValue = LunarCalendarView.getMostAvailableDay()
        }
        else {
            self.queryDate.dateValue = QueryDefaultManager.sharedInstance.lastQueryDate
        }
        
        passengerViewControllerList = [PassengerViewController]()
        
        filterBtn.enabled = false
        filterCbx.enabled = false
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveCheckPassengerMessageNotification(_:)), name: DidSendCheckPassengerMessageNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveDidSendSubmitMessageNotification(_:)), name: DidSendSubmitMessageNotification, object: nil)
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
    }
    
// MARK: - firstSearchView
    @IBOutlet weak var fromStationName: AutoCompleteTextField!
    @IBOutlet weak var toStationName: AutoCompleteTextField!
    @IBOutlet weak var queryDate: NSDatePicker!
    
    var calendarPopover:NSPopover?
   
    private func getDateStr(date:NSDate) -> String{
        let dateDescription = date.description
        let dateRange = dateDescription.rangeOfString(" ")
        return dateDescription[dateDescription.startIndex..<dateRange!.startIndex]
    }
    
    @IBAction func convertCity(sender: NSButton) {
        let temp = self.fromStationName.stringValue
        self.fromStationName.stringValue = self.toStationName.stringValue
        self.toStationName.stringValue = temp
    }
    
    @IBAction func queryTicket(sender: NSButton) {
        if !StationNameJs.sharedInstance.allStationMap.keys.contains(fromStationName.stringValue) {
            print("error fromStationName: \(fromStationName.stringValue)")
            return
            
        }
        
        if !StationNameJs.sharedInstance.allStationMap.keys.contains(toStationName.stringValue) {
            print("error toStationName: \(toStationName.stringValue)")
            return
        }
        
        let date = getDateStr(queryDate.dateValue)
        
        QueryDefaultManager.sharedInstance.lastFromStation = fromStationName.stringValue
        QueryDefaultManager.sharedInstance.lastToStation = toStationName.stringValue
        QueryDefaultManager.sharedInstance.lastQueryDate = queryDate.dateValue
        
        queryLeftTicket(fromStationName.stringValue, toStation: toStationName.stringValue, date: date)
    }
    
// MARK: - secondSearchView
    @IBOutlet weak var passengersView: NSStackView!
    
    var passengerViewControllerList = [PassengerViewController]()
    let passengerSelectViewController = PassengerSelectViewController()
    
    @IBOutlet weak var filterBtn: LoginButton!
    @IBOutlet weak var filterCbx: NSButton!
    
    lazy var passengersPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.passengerSelectViewController
        return popover
    }()
    
    func receiveCheckPassengerMessageNotification(notification: NSNotification) {
        if !self.passengersPopover.shown {
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
    
    func setCanFilter(canFilter:Bool) {
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
        self.filterTrain()
    }
    
    @IBAction func selectPassenger(sender: NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxY
        
        passengersPopover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
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
    
// MARK: - TicketTableView
    @IBOutlet weak var leftTicketTable: NSTableView!
    @IBOutlet weak var tips: FlashLabel!
    
    var service = Service()
    var ticketQueryResult = [QueryLeftNewDTO]()
    var filterQueryResult = [QueryLeftNewDTO]()
    
    var date:String?
    
    var trainFilterKey = ""
    var seatFilterKey = ""
    
    lazy var trainFilterWindowController:TrainFilterWindowController = TrainFilterWindowController()
    lazy var submitWindowController:SubmitWindowController = SubmitWindowController()
    var loadingTipController = LoadingTipViewController(nibName:"LoadingTipViewController",bundle: nil)!
    
    lazy var trainCodeDetailViewController:TrainCodeDetailViewController = TrainCodeDetailViewController()
    lazy var trainCodeDetailPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.trainCodeDetailViewController
        return popover
    }()
    
    func receiveDidSendSubmitMessageNotification(note: NSNotification){
        print("receiveDidSendSubmitMessageNotification")
        submitWindowController = SubmitWindowController()
        if let window = self.view.window {
            window.beginSheet(submitWindowController.window!, completionHandler: {response in
                if response == NSModalResponseOK{
                    ///
                }
            })
        }
    }
    
    func filterTrain(){
        if trainFilterKey == "" {
            trainFilterWindowController = TrainFilterWindowController()
        }
        trainFilterWindowController.trains = ticketQueryResult
        trainFilterWindowController.fromStationName = self.fromStationName.stringValue
        trainFilterWindowController.toStationName = self.toStationName.stringValue
        trainFilterWindowController.trainDate = self.date!
        if let window = self.view.window {
            window.beginSheet(trainFilterWindowController.window!, completionHandler: {response in
                if response == NSModalResponseOK{
                    self.trainFilterKey = self.trainFilterWindowController.trainFilterKey
                    self.seatFilterKey = self.trainFilterWindowController.seatFilterKey
                    print(self.trainFilterKey)
                    print(self.seatFilterKey)
                    
                    self.filterQueryResult = self.ticketQueryResult.filter({item in return self.trainFilterKey.containsString(item.TrainCode!)})
                    self.leftTicketTable.reloadData()
                }
            })
        }
        
    }
    
    func queryLeftTicket(fromStation: String, toStation: String, date: String) {
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            self.ticketQueryResult = tickets
            if self.trainFilterKey != "" {
                self.filterQueryResult = self.ticketQueryResult.filter({item in return self.trainFilterKey.containsString(item.TrainCode!)})
            }
            else {
                self.filterQueryResult = tickets
            }
            
            self.leftTicketTable.reloadData()
            self.loadingTipController.stop()
            
            var canFilterState = false
            if tickets.count > 0 {
                canFilterState = true
            }
            
            self.setCanFilter(canFilterState)
        }
        
        let failureHandler = {(error:NSError)->() in
            self.loadingTipController.stop()
            self.tips.show(translate(error), forDuration: 1, withFlash: false)
            
            self.setCanFilter(false)
        }
        
        self.filterQueryResult = [QueryLeftNewDTO]()
        self.leftTicketTable.reloadData()
        
        self.loadingTipController.start(tip:"正在查询...")
        self.date = date
        if fromStation != self.fromStationName || toStation != self.toStationName {
            trainFilterKey = ""
        }
        
        let fromStationCode = StationNameJs.sharedInstance.allStationMap[fromStation]?.Code
        let toStationCode = StationNameJs.sharedInstance.allStationMap[toStation]?.Code
        var params = LeftTicketParam()
        params.from_stationCode = fromStationCode!
        params.to_stationCode = toStationCode!
        
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
        
        self.loadingTipController.start(tip:"正在提交...")
        
        let postSubmitWindowMessage = {
            self.loadingTipController.stop()
            self.tips.show("提交成功", forDuration: 0.1, withFlash: false)
            
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
    
    func clickTrainCode(sender:NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxX
        trainCodeDetailPopover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
        
        let trainCode = sender.title
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
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
}

// MARK: - AutoCompleteTableViewDelegate
extension TicketQueryViewController: AutoCompleteTableViewDelegate{
    func textField(textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        var matches = [String]()
        //先按简拼  再按全拼  并保留上一次的match
        for station in StationNameJs.sharedInstance.allStation
        {
            if let _ = station.FirstLetter.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
            {
                matches.append(station.Name)
            }
        }
        
        if(matches.isEmpty)
        {
            for station in StationNameJs.sharedInstance.allStation
            {
                if let _ = station.Spell.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
                {
                    matches.append(station.Name)
                }
            }
        }
        //再按汉字
        if(matches.isEmpty)
        {
            for station in StationNameJs.sharedInstance.allStation
            {
                if let _ = station.Name.rangeOfString(textField.stringValue, options: NSStringCompareOptions.AnchoredSearch)
                {
                    matches.append(station.Name)
                }
            }
        }
        
        return matches
    }
}

// MARK: - LunarCalendarViewDelegate
extension TicketQueryViewController: LunarCalendarViewDelegate{
    func createCalenderPopover(){
        var myPopover = self.calendarPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            let cp = LunarCalendarView()
            cp.delegate = self
            cp.date = self.queryDate.dateValue
            cp.selectedDate = self.queryDate.dateValue
            myPopover!.contentViewController = cp
            myPopover!.appearance = NSAppearance(named: "NSAppearanceNameAqua")
            myPopover!.animates = true
            myPopover!.behavior = NSPopoverBehavior.Transient
        }
        self.calendarPopover = myPopover
    }
    
    @IBAction func showCalendar(sender: AnyObject){
        self.createCalenderPopover()
        let cellRect = sender.bounds
        self.calendarPopover?.showRelativeToRect(cellRect, ofView: sender as! NSView, preferredEdge: .MaxY)
    }
    
    func didSelectDate(selectedDate: NSDate) {
        self.queryDate!.dateValue = selectedDate
        self.calendarPopover?.close()
    }
}

// MARK: - NSTableViewDataSource
extension TicketQueryViewController: NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filterQueryResult.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return filterQueryResult[row]
    }
}

// MARK: - NSTableViewDelegate
extension TicketQueryViewController: NSTableViewDelegate{
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return tableView.makeViewWithIdentifier("row", owner: tableView) as? NSTableRowView
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let columnIdentifier = tableColumn!.identifier
        if(columnIdentifier == "余票信息"){
            let cell = view as! TrainInfoTableCellView
            cell.ticketInfo = filterQueryResult[row]
            cell.setTarget(self, action: #selector(TicketQueryViewController.submit(_:)))
        }
        else if(columnIdentifier == "发站" || columnIdentifier == "到站"){
            let cell = view as! TrainTableCellView
            cell.ticketInfo = filterQueryResult[row]
        }
        else if(columnIdentifier == "车次"){
            let cell = view as! TrainCodeTableCellView
            cell.setTarget(self, action:#selector(TicketQueryViewController.clickTrainCode(_:)))
        }
        
        return view
    }
    
}
