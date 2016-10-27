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
        
        self.stackContentView.addView(firstSearchView, inGravity:.Top)
        self.stackContentView.addView(secondSearchView, inGravity: .Top)
        self.stackContentView.addView(ticketTableView, inGravity: .Top)
        
        self.stackContentView.orientation = .Vertical
        self.stackContentView.alignment = .CenterX
        self.stackContentView.spacing = 0
        
        self.fromStationNameTxt.tableViewDelegate = self
        self.toStationNameTxt.tableViewDelegate = self
        
        self.fromStationNameTxt.stringValue = QueryDefaultManager.sharedInstance.lastFromStation
        self.toStationNameTxt.stringValue = QueryDefaultManager.sharedInstance.lastToStation
        
        passengerViewControllerList = [PassengerViewController]()
        
        filterBtn.enabled = false
        filterCbx.enabled = false
        filterBtn.hidden = true
        filterCbx.hidden = true
        autoQueryNumTxt.hidden = true
        
        let menu = NSMenu()
        let item1 = NSMenuItem(title: "成人", action: #selector(TicketQueryViewController.clickTicketTypeSetting(_:)), keyEquivalent: "")
        item1.target = self
        let item2 = NSMenuItem(title: "学生", action: #selector(TicketQueryViewController.clickTicketTypeSetting(_:)), keyEquivalent: "")
        item2.target = self
        menu.addItem(item1)
        menu.addItem(item2)
        ticketTypePopupBtn.menu = menu
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveCheckPassengerMessageNotification(_:)), name: DidSendCheckPassengerMessageNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveLogoutMessageNotification(_:)), name: DidSendLogoutMessageNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveDidSendSubmitMessageNotification(_:)), name: DidSendSubmitMessageNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TicketQueryViewController.receiveAutoSubmitMessageNotification(_:)), name: DidSendAutoSubmitMessageNotification, object: nil)
        
        if QueryDefaultManager.sharedInstance.lastQueryDate.compare(NSDate()) == .OrderedAscending {
            self.setQueryDateValue(LunarCalendarView.getMostAvailableDay())
        }
        else {
            self.setQueryDateValue(QueryDefaultManager.sharedInstance.lastQueryDate)
        }
        
        let descriptorStartTime = NSSortDescriptor(key: TicketOrder.StartTime.rawValue, ascending: true)
        let descriptorArriveTime = NSSortDescriptor(key: TicketOrder.ArriveTime.rawValue, ascending: true)
        let descriptorLishi = NSSortDescriptor(key: TicketOrder.Lishi.rawValue, ascending: true)
        leftTicketTable.tableColumns[1].sortDescriptorPrototype = descriptorStartTime
        leftTicketTable.tableColumns[2].sortDescriptorPrototype = descriptorArriveTime
        leftTicketTable.tableColumns[3].sortDescriptorPrototype = descriptorLishi
    }
    
// MARK: - firstSearchView
    @IBOutlet weak var fromStationNameTxt: AutoCompleteTextField!
    @IBOutlet weak var toStationNameTxt: AutoCompleteTextField!
    @IBOutlet weak var queryDate: ClickableDatePicker!
    @IBOutlet weak var queryBtn: NSButton!
    @IBOutlet weak var converCityBtn: NSButton!
    @IBOutlet weak var dateStepper: NSStepper!
    @IBOutlet weak var autoQueryNumTxt: NSTextField!
    @IBOutlet weak var ticketTypePopupBtn: NSPopUpButton!
    
    var autoQueryNum = 0
    var calendarPopover:NSPopover?
    var repeatTimer:NSTimer?
   
    private func getDateStr(date:NSDate) -> String{
        let dateDescription = date.description
        let dateRange = dateDescription.rangeOfString(" ")
        return dateDescription[dateDescription.startIndex..<dateRange!.startIndex]
    }
    
    private func setQueryDateValue(date:NSDate) {
        let calender = NSCalendar.currentCalendar()
        calender.timeZone = NSTimeZone(abbreviation: "UTC")!
        let trunkNextDate = calender.startOfDayForDate(date)
        let trunkOriginDate = calender.startOfDayForDate(NSDate())
        
        self.queryDate.dateValue = trunkNextDate
        dateStepper.doubleValue = trunkNextDate.timeIntervalSinceDate(trunkOriginDate)/24/3600
    }
    
    func clickTicketTypeSetting(item:NSMenuItem){
//        NSDictionary *dic = [self getVideoModeDic];
//        for (NSNumber* key in [dic allKeys]) {
//            if ([[menuItem title]isEqualToString:[dic objectForKey:key]]) {
//                [mediaItem_ setVRMode: (VR_MODE)[key integerValue]];
//            }
//        }
    }
    
    private func stopAutoQuery(){
        repeatTimer?.invalidate()
        repeatTimer = nil
        hasAutoQuery = false
    }
    
    @IBAction func clickConvertCity(sender: NSButton) {
        let temp = self.fromStationNameTxt.stringValue
        self.fromStationNameTxt.stringValue = self.toStationNameTxt.stringValue
        self.toStationNameTxt.stringValue = temp
    }
    
    @IBAction func clickDateStepper(sender: NSStepper) {
        let date = NSDate(timeIntervalSinceNow: 3600*24*sender.doubleValue)
        self.setQueryDateValue(date)
        
        autoQuery = false
        self.clickQueryTicket(nil)
    }
    
    @IBAction func clickQueryTicket(sender: AnyObject?) {
        
        if !StationNameJs.sharedInstance.allStationMap.keys.contains(self.fromStationNameTxt.stringValue) {
            return
        }
        
        if !StationNameJs.sharedInstance.allStationMap.keys.contains(self.toStationNameTxt.stringValue) {
            return
        }
        
        if hasAutoQuery {
            self.stopAutoQuery()
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
            repeatTimer = NSTimer(timeInterval: Double(GeneralPreferenceManager.sharedInstance.autoQuerySeconds), target: self, selector: #selector(TicketQueryViewController.queryTicketAndSubmit), userInfo: nil, repeats: true)
            repeatTimer?.fire()
            NSRunLoop.currentRunLoop().addTimer(repeatTimer!, forMode: NSDefaultRunLoopMode)
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
                filterCbx.state = NSOnState
            }
            else {
                queryBtn.title = "开始查询"
                self.resetAutoQueryNumStatus()
                filterCbx.state = NSOffState
            }
        }
    }
    
    var hasAutoQuery = false {
        didSet {
            if hasAutoQuery {
                queryBtn.title = "停止抢票"
                self.fromStationNameTxt.enabled = false
                self.toStationNameTxt.enabled = false
                self.converCityBtn.enabled = false
                self.queryDate.clickable = false
                filterCbx.enabled = false
                self.dateStepper.enabled = false
            }
            else {
                queryBtn.title = "开始抢票"
                self.fromStationNameTxt.enabled = true
                self.toStationNameTxt.enabled = true
                self.queryDate.clickable = true
                self.converCityBtn.enabled = true
                filterCbx.enabled = true
                if self.filterQueryResult.count > 0 {
                    canFilter = true
                }
                self.dateStepper.enabled = true
            }
        }
    }
    
    var canFilter = false {
        didSet {
            if canFilter {
                filterBtn.hidden = false
                filterCbx.hidden = false
                filterBtn.enabled = true
                filterCbx.enabled = true
            }
            else {
                filterBtn.enabled = false
                filterCbx.enabled = false
            }
        }
    }
    
    lazy var passengersPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.passengerSelectViewController
        return popover
    }()
    
    func receiveCheckPassengerMessageNotification(notification: NSNotification) {
        if !self.passengersPopover.shown {
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
    
    @IBAction func clickAutoQuery(sender: NSButton) {
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
    
    @IBAction func clickFilterTrain(sender: AnyObject) {
        self.filterTrain()
    }
    
    @IBAction func clickAddPassenger(sender: NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxY
        
        passengersPopover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
        passengerSelectViewController.reloadPassenger(MainModel.passengers)
    }
    
// MARK: - TicketTableView
    @IBOutlet weak var leftTicketTable: NSTableView!
    
    var service = Service()
    var ticketQueryResult = [QueryLeftNewDTO]()
    var filterQueryResult = [QueryLeftNewDTO]()
    
    var date:String?
    
    var ticketOrder:TicketOrder?
    var ticketAscending:Bool?
    
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
    
    lazy var trainCodeDetailViewController:TrainCodeDetailViewController = TrainCodeDetailViewController()
    lazy var trainCodeDetailPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = self.trainCodeDetailViewController
        return popover
    }()
    
    func receiveDidSendSubmitMessageNotification(note: NSNotification){
        openSubmitSheet(isAutoSubmit: false)
    }
    
    func receiveAutoSubmitMessageNotification(note: NSNotification){
        openSubmitSheet(isAutoSubmit: true)
    }
    
    func openSubmitSheet(isAutoSubmit isAutoSubmit:Bool) {
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
    
    func ticketOrderedBy(tickets:[QueryLeftNewDTO], orderedBy:TicketOrder, ascending:Bool) -> [QueryLeftNewDTO] {
        let sortedTickets:[QueryLeftNewDTO] = tickets.sort{
            var isOriginAscending = true
            switch orderedBy
            {
            case .StartTime:
                isOriginAscending = $0.start_time < $1.start_time
            case .ArriveTime:
                isOriginAscending = $0.arrive_time < $1.arrive_time
            case .Lishi:
                isOriginAscending = $0.lishi < $1.lishi
            }
                
            if ascending {
                return isOriginAscending
            }
            else {
                return !isOriginAscending
            }
        }
        
        return sortedTickets
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
                    
                    self.filterQueryResult = self.ticketQueryResult.filter({item in return self.trainFilterKey.containsString("|" + item.TrainCode! + "|")})
                    
                    if let ticketOrderX = self.ticketOrder, let ticketAscendingX = self.ticketAscending {
                        self.filterQueryResult = self.ticketOrderedBy(self.filterQueryResult, orderedBy: ticketOrderX, ascending: ticketAscendingX)
                    }
                    
                    self.leftTicketTable.reloadData()
                    
                    if GeneralPreferenceManager.sharedInstance.isAutoQueryAfterFilter {
                        self.autoQuery = true
                    }
                }
                else {
                    self.autoQuery = false;
                }
            })
        }
    }
    
    func queryTicketAndSubmit() {
        let summitHandler = {
            self.addAutoQueryNumStatus()
            
            for ticket in self.filterQueryResult {
                if ticket.hasTicketForSeatTypeFilterKey(self.seatFilterKey) {
                    self.stopAutoQuery()
                    
                    let seatTypeId = ticket.getSeatTypeNameByFilterKey(self.seatFilterKey)!
                    self.summitTicket(ticket, seatTypeId: seatTypeId,isAuto: true)
                    
                    NotifySpeaker.sharedInstance.notify()
                    
                    let informativeText = "\(self.date!) \(self.fromStationNameTxt.stringValue)->\(self.toStationNameTxt.stringValue) \(seatTypeId)"
                    self.pushUserNotification("有票提醒",informativeText: informativeText)
                    
                    break;
                }
            }
        }
        queryLeftTicket(summitHandler)
    }
    
    func addAutoQueryNumStatus() {
        self.autoQueryNum += 1
        self.autoQueryNumTxt.hidden = false
        self.autoQueryNumTxt.stringValue = "已查询\(self.autoQueryNum)次"
    }
    
    func resetAutoQueryNumStatus() {
        self.autoQueryNum = 0
        self.autoQueryNumTxt.hidden = true
    }
    
    func showTip(tip:String){
        DJTipHUD.showStatus(tip, fromView: self.view)
    }
    
    func startLoadingTip(tip:String)
    {
        DJLayerView.showStatus(tip, fromView: self.view)
    }
    
    func stopLoadingTip(){
        DJLayerView.dismiss()
    }
    
    func queryLeftTicket(summitHandler:()->() = {}) {
        let fromStation = self.fromStationNameTxt.stringValue
        let toStation = self.toStationNameTxt.stringValue
        let date = getDateStr(queryDate.dateValue)
        
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            self.ticketQueryResult = tickets
            
            self.filterQueryResult = self.ticketQueryResult.filter({item in
                var isReturn = true
                if self.trainFilterKey != "" {
                    isReturn = self.trainFilterKey.containsString("|\(item.TrainCode)|")
                }
                if (item.isTicketInvalid()) && (!GeneralPreferenceManager.sharedInstance.isShowInvalidTicket) {
                    isReturn = false
                }
                if (!item.hasTicket)&&(!GeneralPreferenceManager.sharedInstance.isShowNoTrainTicket){
                    isReturn = false
                }
                
                return isReturn
            })
            
            if let ticketOrderX = self.ticketOrder, let ticketAscendingX = self.ticketAscending {
                self.filterQueryResult = self.ticketOrderedBy(self.filterQueryResult, orderedBy: ticketOrderX, ascending: ticketAscendingX)
            }
        
            self.leftTicketTable.reloadData()
            self.stopLoadingTip()
            
            if ((tickets.count > 0) && (!self.hasAutoQuery)) {
                self.canFilter = true
            }
            else {
                self.canFilter = false
            }
            
            summitHandler()
        }
        
        let failureHandler = {(error:NSError)->() in
            self.filterQueryResult = [QueryLeftNewDTO]()
            self.leftTicketTable.reloadData()
            
            self.stopLoadingTip()
            self.showTip(translate(error))
            
            self.canFilter = false
        }
        
        self.startLoadingTip("正在查询...")
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
    
    func setSeatCodeForSelectedPassenger(trainCode:String, seatCodeName:String){
        for passenger in MainModel.selectPassengers{
            passenger.seatCodeName = seatCodeName
            passenger.seatCode = QuerySeatTypeDicBy(trainCode)[seatCodeName]!
        }
    }
    
    func pushUserNotification(title:String, informativeText:String){
        let notification:NSUserNotification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        notification.deliveryDate = NSDate()
        notification.soundName = NSUserNotificationDefaultSoundName
        
        let center = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.scheduleNotification(notification)
        center.delegate = self
    }
    
    func summitTicket(ticket:QueryLeftNewDTO,seatTypeId:String,isAuto:Bool){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        if !MainModel.isGetUserInfo {
            notificationCenter.postNotificationName(DidSendAutoLoginMessageNotification, object: nil)
            return
        }
        
        setSelectedPassenger()
        
        if MainModel.selectPassengers.count == 0 {
            self.showTip("请先选择乘客")
            return
        }
        
        MainModel.selectedTicket = ticket
        setSeatCodeForSelectedPassenger(MainModel.selectedTicket!.TrainCode! ,seatCodeName: seatTypeId)
        
        self.startLoadingTip("正在提交...")
        
        let postSubmitWindowMessage = {
            self.stopLoadingTip()
            
            if isAuto {
                notificationCenter.postNotificationName(DidSendAutoSubmitMessageNotification, object: nil)
            }
            else {
                notificationCenter.postNotificationName(DidSendSubmitMessageNotification, object: nil)
            }
        }
        
        let failHandler = {(error:NSError)->() in
            self.stopLoadingTip()
            
            if error.code == ServiceError.Code.CheckUserFailed.rawValue {
                notificationCenter.postNotificationName(DidSendLoginMessageNotification, object: nil)
            }else{
                self.showTip(translate(error))
            }
        }
        
        service.submitFlow(success: postSubmitWindowMessage, failure: failHandler)
    }
    
    func clickSubmit(sender: NSButton){
        if hasAutoQuery {
            self.stopAutoQuery()
        }
        let selectedRow = leftTicketTable.rowForView(sender)
        let ticket = filterQueryResult[selectedRow]
        let seatTypeId = sender.identifier!
        
        self.summitTicket(ticket, seatTypeId: seatTypeId,isAuto: false)
    }
    
    func clickShowTrainDetail(sender:NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxX
        trainCodeDetailPopover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)
        
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
        self.setQueryDateValue(selectedDate)
        self.calendarPopover?.close()
        
        autoQuery = false
        self.clickQueryTicket(nil)
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
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        if let ticketOrder = TicketOrder(rawValue: sortDescriptor.key!) {
            self.filterQueryResult = self.ticketOrderedBy(self.filterQueryResult, orderedBy: ticketOrder, ascending: sortDescriptor.ascending)
            self.ticketOrder = ticketOrder
            self.ticketAscending = sortDescriptor.ascending
            self.leftTicketTable.reloadData()
        }
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

// MARK: - NSUserNotificationCenterDelegate
extension TicketQueryViewController:NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        self.view.window?.makeKeyAndOrderFront(nil)
//        NSApp.activateIgnoringOtherApps(false)
        center.removeDeliveredNotification(notification)
    }
}
