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
    
    override var nibName: String? {
        return "TicketQueryViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackContentView.addView(firstSearchView, in:.top)
        self.stackContentView.addView(secondSearchView, in: .top)
        self.stackContentView.addView(ticketTableView, in: .top)
        
        self.stackContentView.orientation = .vertical
        self.stackContentView.alignment = .centerX
        self.stackContentView.spacing = 0
        
        self.fromStationNameTxt.tableViewDelegate = self
        self.toStationNameTxt.tableViewDelegate = self
        
        self.fromStationNameTxt.stringValue = QueryDefaultManager.sharedInstance.lastFromStation
        self.toStationNameTxt.stringValue = QueryDefaultManager.sharedInstance.lastToStation
        
        if QueryDefaultManager.sharedInstance.lastQueryDate.compare(Date()) == .orderedAscending {
            self.queryDate.dateValue = LunarCalendarView.getMostAvailableDay() as Date
        }
        else {
            self.queryDate.dateValue = QueryDefaultManager.sharedInstance.lastQueryDate as Date
        }
        
        passengerViewControllerList = [PassengerViewController]()
        
        filterBtn.isEnabled = false
        filterCbx.isEnabled = false
        filterBtn.isHidden = true
        filterCbx.isHidden = true
        autoQueryNumTxt.isHidden = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receiveCheckPassengerMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendCheckPassengerMessageNotification), object: nil)
        notificationCenter.addObserver(self, selector: #selector(receiveLogoutMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendLogoutMessageNotification), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(receiveDidSendSubmitMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendSubmitMessageNotification), object: nil)
        notificationCenter.addObserver(self, selector: #selector(receiveAutoSubmitMessageNotification(_:)), name: NSNotification.Name(rawValue: DidSendAutoSubmitMessageNotification), object: nil)
        
        //init loadingTipView
        self.view.addSubview(loadingTipController.view)
        self.loadingTipController.setCenterConstrainBy(view: self.view)
        self.loadingTipController.setTipView(isHidden: true)
    }
    
// MARK: - firstSearchView
    @IBOutlet weak var fromStationNameTxt: AutoCompleteTextField!
    @IBOutlet weak var toStationNameTxt: AutoCompleteTextField!
    @IBOutlet weak var queryDate: ClickableDatePicker!
    @IBOutlet weak var queryBtn: NSButton!
    @IBOutlet weak var converCityBtn: NSButton!
    
    @IBOutlet weak var autoQueryNumTxt: NSTextField!
    var autoQueryNum = 0
    var calendarPopover:NSPopover?
    var repeatTimer:Timer?
   
    fileprivate func getDateStr(_ date:Date) -> String{
        let dateDescription = date.description
        let dateRange = dateDescription.range(of: " ")
        return dateDescription[dateDescription.startIndex..<dateRange!.lowerBound]
    }
    
    @IBAction func clickConvertCity(_ sender: NSButton) {
        let temp = self.fromStationNameTxt.stringValue
        self.fromStationNameTxt.stringValue = self.toStationNameTxt.stringValue
        self.toStationNameTxt.stringValue = temp
    }
    
    @IBAction func clickQueryTicket(_ sender: NSButton) {
        if !StationNameJs.sharedInstance.allStationMap.keys.contains(self.fromStationNameTxt.stringValue) {
            return
        }
        
        if !StationNameJs.sharedInstance.allStationMap.keys.contains(self.toStationNameTxt.stringValue) {
            return
        }
        
        if hasAutoQuery {
            repeatTimer?.invalidate()
            repeatTimer = nil
            hasAutoQuery = false
            return
        }
        
        if self.fromStationNameTxt.stringValue != QueryDefaultManager.sharedInstance.lastFromStation ||
            self.toStationNameTxt.stringValue != QueryDefaultManager.sharedInstance.lastToStation {
            trainFilterKey = ""
        }
        
        QueryDefaultManager.sharedInstance.lastFromStation = self.fromStationNameTxt.stringValue
        QueryDefaultManager.sharedInstance.lastToStation = self.toStationNameTxt.stringValue
        QueryDefaultManager.sharedInstance.lastQueryDate = queryDate.dateValue
        
        if autoQuery {
            repeatTimer = Timer(timeInterval: Double(GeneralPreferenceManager.sharedInstance.autoQuerySeconds), target: self, selector: #selector(TicketQueryViewController.queryTicketAndSubmit), userInfo: nil, repeats: true)
            repeatTimer?.fire()
            RunLoop.current.add(repeatTimer!, forMode: RunLoopMode.defaultRunLoopMode)
            hasAutoQuery = true
        }
        else {
            queryLeftTicket()
        }
    }
    
// MARK: - secondSearchView
    @IBOutlet weak var passengersView: NSStackView!
    
    var passengerViewControllerList = [PassengerViewController]()
    let passengerSelectViewController = PassengerSelectViewController()
    
    @IBOutlet weak var filterBtn: LoginButton!
    @IBOutlet weak var filterCbx: NSButton!
    
    var autoQuery = false {
        didSet {
            if autoQuery {
                queryBtn.title = "开始抢票"
            }
            else {
                queryBtn.title = "开始查询"
                self.resetAutoQueryNumStatus()
            }
        }
    }
    
    var hasAutoQuery = false {
        didSet {
            if hasAutoQuery {
                queryBtn.title = "停止抢票"
                self.fromStationNameTxt.isEnabled = false
                self.toStationNameTxt.isEnabled = false
                self.converCityBtn.isEnabled = false
                self.queryDate.clickable = false
                filterCbx.isEnabled = false
            }
            else {
                queryBtn.title = "开始抢票"
                self.fromStationNameTxt.isEnabled = true
                self.toStationNameTxt.isEnabled = true
                self.queryDate.clickable = true
                self.converCityBtn.isEnabled = true
                filterCbx.isEnabled = true
                if self.filterQueryResult.count > 0 {
                    canFilter = true
                }
            }
        }
    }
    
    var canFilter = false {
        didSet {
            if canFilter {
                filterBtn.isHidden = false
                filterCbx.isHidden = false
                filterBtn.isEnabled = true
                filterCbx.isEnabled = true
            }
            else {
                filterBtn.isEnabled = false
                filterCbx.isEnabled = false
            }
        }
    }
    
    lazy var passengersPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = self.passengerSelectViewController
        return popover
    }()
    
    func receiveCheckPassengerMessageNotification(_ notification: Notification) {
        if !self.passengersPopover.isShown {
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
                    self.passengersView.addView(p.view, in:.top)
                }
                
                break
            }
        }
    }
    
    func receiveLogoutMessageNotification(_ notification: Notification) {
        passengerViewControllerList.removeAll()
        for view in passengersView.views{
            view.removeFromSuperview()
        }
    }
    
    @IBAction func clickAutoQuery(_ sender: NSButton) {
        if sender.state == NSOnState {
            if self.seatFilterKey == "" {
                self.filterTrain()
            }
            else {
                autoQuery = true
            }
        }
        else {
            autoQuery = false
        }
    }
    
    @IBAction func clickFilterTrain(_ sender: AnyObject) {
        self.filterTrain()
    }
    
    @IBAction func clickAddPassenger(_ sender: NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.maxY
        
        passengersPopover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        passengerSelectViewController.reloadPassenger(MainModel.passengers)
    }
    
    func passengerSelected(_ passenger:PassengerDTO) -> Bool{
        for controller in passengerViewControllerList where controller.passenger == passenger{
            return true
        }
        return false
    }
    
    func checkPassenger(_ passenger:PassengerDTO){
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
    
    var trainFilterKey = "" {
        didSet {
            if trainFilterKey == "" {
                trainFilterWindowController = TrainFilterWindowController()
            }
        }
    }
    
    var seatFilterKey = ""
    
    lazy var trainFilterWindowController:TrainFilterWindowController = TrainFilterWindowController()
    lazy var submitWindowController:SubmitWindowController = SubmitWindowController()
    lazy var loadingTipController:LoadingTipViewController = LoadingTipViewController()
    
    lazy var trainCodeDetailViewController:TrainCodeDetailViewController = TrainCodeDetailViewController()
    lazy var trainCodeDetailPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = self.trainCodeDetailViewController
        return popover
    }()
    
    func receiveDidSendSubmitMessageNotification(_ note: Notification){
        openSubmitSheet(isAutoSubmit: false)
    }
    
    func receiveAutoSubmitMessageNotification(_ note: Notification){
        openSubmitSheet(isAutoSubmit: true)
    }
    
    func openSubmitSheet(isAutoSubmit:Bool) {
        submitWindowController = SubmitWindowController()
        submitWindowController.isAutoSubmit = isAutoSubmit
        if let window = self.view.window {
            window.beginSheet(submitWindowController.window!, completionHandler: {response in
                if response == NSModalResponseOK{
                    ///
                }
            })
        }
    }
    
    func filterTrain(){
        trainFilterWindowController.trains = ticketQueryResult.filter({item in
            return !item.isTicketInvalid()
        })
        trainFilterWindowController.fromStationName = self.fromStationNameTxt.stringValue
        trainFilterWindowController.toStationName = self.toStationNameTxt.stringValue
        trainFilterWindowController.trainDate = self.date!
        
        
        if let window = self.view.window {
            window.beginSheet(trainFilterWindowController.window!, completionHandler: {response in
                if response == NSModalResponseOK{
                    self.trainFilterKey = self.trainFilterWindowController.trainFilterKey
                    self.seatFilterKey = self.trainFilterWindowController.seatFilterKey
                    logger.info("trainFilterKey:\(self.trainFilterKey) seatFilterKey:\(self.seatFilterKey)")
                    
                    self.filterQueryResult = self.ticketQueryResult.filter({item in return self.trainFilterKey.contains("|" + item.TrainCode! + "|")})
                    self.leftTicketTable.reloadData()
                    
                    self.filterCbx.state = NSOnState
                    self.autoQuery = true
                }
            })
        }
    }
    
    func queryTicketAndSubmit() {
        let summitHandler = {
            self.addAutoQueryNumStatus()
            
            for ticket in self.filterQueryResult {
                if ticket.hasTicketForSeatTypeFilterKey(self.seatFilterKey) {
                    //停止查询
                    self.repeatTimer?.invalidate()
                    self.repeatTimer = nil
                    self.hasAutoQuery = false
                    self.autoSummit(ticket, seatTypeId: ticket.getSeatTypeNameByFilterKey(self.seatFilterKey)!)
                    NotifySpeaker.sharedInstance.notify()
                    break;
                }
            }
        }
        queryLeftTicket(summitHandler)
    }
    
    func addAutoQueryNumStatus() {
        self.autoQueryNum += 1
        self.autoQueryNumTxt.isHidden = false
        self.autoQueryNumTxt.stringValue = "已查询\(self.autoQueryNum)次"
    }
    
    func resetAutoQueryNumStatus() {
        self.autoQueryNum = 0
        self.autoQueryNumTxt.isHidden = true
    }
    
    func queryLeftTicket(_ summitHandler:@escaping ()->() = {}) {
        let fromStation = self.fromStationNameTxt.stringValue
        let toStation = self.toStationNameTxt.stringValue
        let date = getDateStr(queryDate.dateValue)
        
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            self.ticketQueryResult = tickets
            
            self.filterQueryResult = self.ticketQueryResult.filter({item in
                var isReturn = true
                if self.trainFilterKey != "" {
                    isReturn = self.trainFilterKey.contains("|\(item.TrainCode)|")
                }
                if (item.isTicketInvalid()) && (!GeneralPreferenceManager.sharedInstance.isShowInvalidTicket) {
                    isReturn = false
                }
                if (!item.hasTicket)&&(!GeneralPreferenceManager.sharedInstance.isShowNoTrainTicket){
                    isReturn = false
                }
                
                return isReturn
            })
        
            self.leftTicketTable.reloadData()
            self.loadingTipController.stop()
            
            if ((tickets.count > 0) && (!self.hasAutoQuery)) {
                self.canFilter = true
            }
            else {
                self.canFilter = false
            }
            
            summitHandler()
        }
        
        let failureHandler = {(error:NSError)->() in
            self.loadingTipController.stop()
            self.tips.show(translate(error), forDuration: 1, withFlash: false)
            
            self.canFilter = false
        }
        
        self.filterQueryResult = [QueryLeftNewDTO]()
        self.leftTicketTable.reloadData()
        
        self.loadingTipController.start(tip:"正在查询...")
        self.date = date
        
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
    
    func setSeatCodeForSelectedPassenger(_ trainCode:String, seatCodeName:String){
        for passenger in MainModel.selectPassengers{
            passenger.seatCodeName = seatCodeName
            passenger.seatCode = QuerySeatTypeDicBy(trainCode)[seatCodeName]!
        }
    }
    
    func autoSummit(_ ticket:QueryLeftNewDTO,seatTypeId:String){
        let notificationCenter = NotificationCenter.default
        
        if !MainModel.isGetUserInfo {
            notificationCenter.post(name: Notification.Name(rawValue: DidSendAutoLoginMessageNotification), object: nil)
            return
        }
        
        setSelectedPassenger()
        
        if MainModel.selectPassengers.count == 0 {
            tips.show("请先选择乘客", forDuration: 0.1, withFlash: false)
            return
        }
        
        MainModel.selectedTicket = ticket
        setSeatCodeForSelectedPassenger(MainModel.selectedTicket!.TrainCode! ,seatCodeName: seatTypeId)
        
        self.loadingTipController.start(tip:"正在提交...")
        
        let postSubmitWindowMessage = {
            self.loadingTipController.stop()
            self.tips.show("提交成功", forDuration: 0.1, withFlash: false)
            
            notificationCenter.post(name: Notification.Name(rawValue: DidSendAutoSubmitMessageNotification), object: nil)
        }
        
        let failHandler = {(error:NSError)->() in
            self.loadingTipController.stop()
            
            if error.code == ServiceError.Code.checkUserFailed.rawValue {
                notificationCenter.post(name: Notification.Name(rawValue: DidSendLoginMessageNotification), object: nil)
            }else{
                self.tips.show(translate(error), forDuration: 0.1, withFlash: false)
            }
        }
        service.submitFlow(postSubmitWindowMessage, failure: failHandler)
    }
    
    func clickSubmit(_ sender: NSButton){
        let notificationCenter = NotificationCenter.default
        
        if !MainModel.isGetUserInfo {
            notificationCenter.post(name: Notification.Name(rawValue: DidSendLoginMessageNotification), object: nil)
            return
        }
        
        setSelectedPassenger()
        
        if MainModel.selectPassengers.count == 0 {
            tips.show("请先选择乘客", forDuration: 0.1, withFlash: false)
            return
        }
        
        let selectedRow = leftTicketTable.row(for: sender)
        MainModel.selectedTicket = filterQueryResult[selectedRow]
        setSeatCodeForSelectedPassenger(MainModel.selectedTicket!.TrainCode ,seatCodeName: sender.identifier!)
        
        self.loadingTipController.start(tip:"正在提交...")
        
        let postSubmitWindowMessage = {
            self.loadingTipController.stop()
            self.tips.show("提交成功", forDuration: 0.1, withFlash: false)
            
            notificationCenter.post(name: Notification.Name(rawValue: DidSendSubmitMessageNotification), object: nil)
        }
        
        let failHandler = {(error:NSError)->() in
            self.loadingTipController.stop()
            
            if error.code == ServiceError.Code.checkUserFailed.rawValue {
                notificationCenter.post(name: Notification.Name(rawValue: DidSendLoginMessageNotification), object: nil)
            } else {
                self.tips.show(translate(error), forDuration: 0.1, withFlash: false)
            }
        }
        service.submitFlow(postSubmitWindowMessage, failure: failHandler)
    }
    
    func clickShowTrainDetail(_ sender:NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.maxX
        trainCodeDetailPopover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        
        let trainCode = sender.title
        var queryByTrainCodeParam = QueryByTrainCodeParam()
        queryByTrainCodeParam.depart_date = self.date!
        
        for i in 0..<ticketQueryResult.count {
            if ticketQueryResult[i].TrainCode == trainCode {
                queryByTrainCodeParam.train_no = ticketQueryResult[i].train_no
                queryByTrainCodeParam.from_station_telecode = ticketQueryResult[i].FromStationCode!
                queryByTrainCodeParam.to_station_telecode = ticketQueryResult[i].ToStationCode!
                break
            }
        }
        
        self.trainCodeDetailViewController.queryByTrainCodeParam = queryByTrainCodeParam
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
}

// MARK: - AutoCompleteTableViewDelegate
extension TicketQueryViewController: AutoCompleteTableViewDelegate{
    func textField(_ textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        var matches = [String]()
        //先按简拼  再按全拼  并保留上一次的match
        for station in StationNameJs.sharedInstance.allStation
        {
            if let _ = station.FirstLetter.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
            {
                matches.append(station.Name)
            }
        }
        
        if(matches.isEmpty)
        {
            for station in StationNameJs.sharedInstance.allStation
            {
                if let _ = station.Spell.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
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
                if let _ = station.Name.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
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
            myPopover!.behavior = NSPopoverBehavior.transient
        }
        self.calendarPopover = myPopover
    }
    
    @IBAction func showCalendar(_ sender: AnyObject){
        self.createCalenderPopover()
        let cellRect = sender.bounds
        self.calendarPopover?.show(relativeTo: cellRect!, of: sender as! NSView, preferredEdge: .maxY)
    }
    
    func didSelectDate(_ selectedDate: Date) {
        self.queryDate!.dateValue = selectedDate
        self.calendarPopover?.close()
    }
}

// MARK: - NSTableViewDataSource
extension TicketQueryViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filterQueryResult.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return filterQueryResult[row]
    }
}

// MARK: - NSTableViewDelegate
extension TicketQueryViewController: NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return tableView.make(withIdentifier: "row", owner: tableView) as? NSTableRowView
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let columnIdentifier = tableColumn!.identifier
        if(columnIdentifier == "余票信息"){
            let cell = view as! TrainInfoTableCellView
            cell.ticketInfo = filterQueryResult[row]
            cell.setTarget(self, action: #selector(TicketQueryViewController.clickSubmit(_:)))
        }
        else if(columnIdentifier == "发站" || columnIdentifier == "到站"){
            let cell = view as! TrainTableCellView
            cell.ticketInfo = filterQueryResult[row]
        }
        else if(columnIdentifier == "车次"){
            let cell = view as! TrainCodeTableCellView
            cell.setTarget(self, action:#selector(TicketQueryViewController.clickShowTrainDetail(_:)))
        }
        
        return view
    }
    
}
