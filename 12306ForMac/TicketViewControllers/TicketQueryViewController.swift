//
//  TicketQueryMainViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/13.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TicketQueryViewController: BaseViewController {
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
        
        passengerViewControllerList = [PassengerViewController]()
        
        filterBtn.isEnabled = false
        filterCbx.isEnabled = false
        filterBtn.isHidden = true
        filterCbx.isHidden = true
        addPassengerBtn.isHidden = true
        autoQueryNumTxt.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(TicketQueryViewController.recvCheckPassengerNotification(_:)), name: NSNotification.Name.App.DidCheckPassenger, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TicketQueryViewController.recvLogoutNotification(_:)), name: NSNotification.Name.App.DidLogout, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TicketQueryViewController.recvDidSubmitNotification(_:)), name: NSNotification.Name.App.DidSubmit, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TicketQueryViewController.recvAutoSubmitNotification(_:)), name: NSNotification.Name.App.DidAutoSubmit, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TicketQueryViewController.recvAddDefaultPassengerNotification(_:)), name: NSNotification.Name.App.DidAddDefaultPassenger, object: nil)
        
        if QueryDefaultManager.sharedInstance.lastQueryDate.compare(Date()) == .orderedAscending {
            self.setQueryDateValue(Date())
        }
        else {
            self.setQueryDateValue(QueryDefaultManager.sharedInstance.lastQueryDate as Date)
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
    
    var autoQueryNum = 0
    var calendarPopover:NSPopover?
    var repeatTimer:Timer?
    var ticketType:TicketType = .Normal
   
    fileprivate func getDateStr(_ date:Date) -> String{
        let dateDescription = date.description
        let dateRange = dateDescription.range(of: " ")
        return dateDescription[dateDescription.startIndex..<dateRange!.lowerBound]
    }
    
    fileprivate func setQueryDateValue(_ date:Date) {
        var calender = Calendar.current
        calender.timeZone = TimeZone(abbreviation: "UTC")!
        let trunkNextDate = calender.startOfDay(for: date)
        let trunkOriginDate = calender.startOfDay(for: Date())
        
        self.queryDate.dateValue = trunkNextDate
        dateStepper.doubleValue = trunkNextDate.timeIntervalSince(trunkOriginDate)/24/3600
    }
    
    fileprivate func stopAutoQuery(){
        repeatTimer?.invalidate()
        repeatTimer = nil
        hasAutoQuery = false
    }
    
    @IBAction func clickConvertCity(_ sender: NSButton) {
        let temp = self.fromStationNameTxt.stringValue
        self.fromStationNameTxt.stringValue = self.toStationNameTxt.stringValue
        self.toStationNameTxt.stringValue = temp
    }
    
    @IBAction func clickDateStepper(_ sender: NSStepper) {
        let date = Date(timeIntervalSinceNow: 3600*24*sender.doubleValue)
        self.setQueryDateValue(date)
        
        autoQuery = false
        self.clickQueryTicket(nil)
    }
    
    @IBAction func clickQueryTicket(_ sender: AnyObject?) {
        
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
        
        self.saveLastSelectdPassengerIdToDefault()
        
        if autoQuery {
            repeatTimer = Timer(timeInterval: Double(GeneralPreferenceManager.sharedInstance.autoQuerySeconds), target: self, selector: #selector(TicketQueryViewController.queryTicketAndSubmit), userInfo: nil, repeats: true)
            repeatTimer?.fire()
            RunLoop.current.add(repeatTimer!, forMode: RunLoopMode.defaultRunLoopMode)
            hasAutoQuery = true
        }
        else {
            queryTicket()
        }
    }
    
// MARK: - secondSearchView
    @IBOutlet weak var passengersView: NSStackView!
    
    var passengerViewControllerList = [PassengerViewController]()
    let passengerSelectViewController = PassengerSelectViewController()
    
    @IBOutlet weak var filterBtn: LoginButton!
    @IBOutlet weak var filterCbx: NSButton!
    @IBOutlet weak var addPassengerBtn: LoginButton!
    
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
                self.fromStationNameTxt.isEnabled = false
                self.toStationNameTxt.isEnabled = false
                self.converCityBtn.isEnabled = false
                self.queryDate.clickable = false
                filterCbx.isEnabled = false
                self.dateStepper.isEnabled = false
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
                self.dateStepper.isEnabled = true
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
    
    func recvCheckPassengerNotification(_ notification: Notification) {
        let passengerId = notification.object as! String
        
        for passenger in MainModel.passengers where passenger.passenger_id_no == passengerId {
            if passengerSelected(passenger){
                checkPassenger(passenger)
            }
            else{
                let passengerViewController = PassengerViewController()
                passengerViewController.passenger = passenger
                passengerViewControllerList.append(passengerViewController)
                self.passengersView.addView(passengerViewController.view, in:.top)
            }
            
            break
        }
    }
    
    func recvAddDefaultPassengerNotification(_ notification: Notification) {
        self.addPassengerBtn.isHidden = false
        if MainModel.passengers.count == 0 {
            return
        }
        if let lastPassengers = QueryDefaultManager.sharedInstance.lastSelectedPassenger {
            if lastPassengers == "" {
                return
            }
            
            let passengerIds = lastPassengers.components(separatedBy: ",")
            for passengerId in passengerIds {
                for passenger in MainModel.passengers where passenger.passenger_id_no == passengerId {
                    passenger.isChecked = true
                    let passengerViewController = PassengerViewController()
                    passengerViewController.passenger = passenger
                    passengerViewControllerList.append(passengerViewController)
                    self.passengersView.addView(passengerViewController.view, in:.top)
                }
            }
        }
    }
    
    func recvLogoutNotification(_ notification: Notification) {
        passengerViewControllerList.removeAll()
        for view in passengersView.views{
            view.removeFromSuperview()
        }
        addPassengerBtn.isHidden = true
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
    
// MARK: - TicketTableView
    @IBOutlet weak var leftTicketTable: NSTableView!
    
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
        popover.behavior = .semitransient
        popover.contentViewController = self.trainCodeDetailViewController
        return popover
    }()
    
    func recvDidSubmitNotification(_ note: Notification){
        openSubmitSheet(isAutoSubmit: false)
    }
    
    func recvAutoSubmitNotification(_ note: Notification){
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
    
    func ticketOrderedBy(_ tickets:[QueryLeftNewDTO], orderedBy:TicketOrder, ascending:Bool) -> [QueryLeftNewDTO] {
        let sortedTickets:[QueryLeftNewDTO] = tickets.sorted{
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
                    logger.info("trainFilterKey:\(self.trainFilterKey)")
                    logger.info("seatFilterKey:\(self.seatFilterKey)")
                    
                    self.filterQueryResult = self.ticketQueryResult.filter({item in return self.trainFilterKey.contains("|" + item.TrainCode! + "|")})
                    
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
                    
                    let informativeText = "\(self.date!) \(self.fromStationNameTxt.stringValue)->\(self.toStationNameTxt.stringValue) \(ticket.TrainCode!) \(seatTypeId)"
                    self.pushUserNotification("有票提醒",informativeText: informativeText)
                    
                    break;
                }
            }
        }
        queryTicket(summitHandler)
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
    
    func queryTicket(_ summitHandler:@escaping ()->() = {}) {
        let fromStation = self.fromStationNameTxt.stringValue
        let toStation = self.toStationNameTxt.stringValue
        let date = getDateStr(queryDate.dateValue)
        
        logger.info("\(fromStation) -> \(toStation) \(date)  \(self.autoQueryNum)")
        
        let successHandler = { (tickets:[QueryLeftNewDTO])->()  in
            self.ticketQueryResult = tickets
            
            self.filterQueryResult = self.ticketQueryResult.filter({item in
                var isReturn = true
                if self.trainFilterKey != "" {
                    isReturn = self.trainFilterKey.contains("|\(item.TrainCode!)|")
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
        params.purpose_codes = ticketType.rawValue
        
        Service.sharedInstance.queryTicketFlowWith(params, success: successHandler,failure: failureHandler)
    }
    
    func setSelectedPassenger(){
        MainModel.selectPassengers = [PassengerDTO]()
        
        for p in MainModel.passengers where p.isChecked {
            MainModel.selectPassengers.append(p)
        }
    }
    
    func saveLastSelectdPassengerIdToDefault(){
        var lastSelectedPassengerId = ""
        
        for p in MainModel.passengers where p.isChecked {
            lastSelectedPassengerId += "\(p.passenger_id_no),"
        }
        
        if lastSelectedPassengerId != "" {
            QueryDefaultManager.sharedInstance.lastSelectedPassenger = lastSelectedPassengerId
        }
    }
    
    func setSeatCodeForSelectedPassenger(_ trainCode:String, seatCodeName:String){
        for passenger in MainModel.selectPassengers{
            passenger.seatCodeName = seatCodeName
            passenger.seatCode = G_QuerySeatTypeNameDicBy(trainCode)[seatCodeName]!
            passenger.setDefaultTicketType(date: self.queryDate.dateValue)
        }
    }
    
    func pushUserNotification(_ title:String, informativeText:String){
        let notification:NSUserNotification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        notification.deliveryDate = Date()
        notification.soundName = NSUserNotificationDefaultSoundName
        
        let center = NSUserNotificationCenter.default
        center.scheduleNotification(notification)
        center.delegate = self
    }
    
    func summitTicket(_ ticket:QueryLeftNewDTO,seatTypeId:String,isAuto:Bool){
        let notificationCenter = NotificationCenter.default
        
        if !MainModel.isGetUserInfo {
            notificationCenter.post(name: Notification.Name.App.DidAutoLogin, object: nil)
            return
        }
        
        setSelectedPassenger()
        
        if MainModel.selectPassengers.count == 0 {
            self.showTip("请先选择乘客")
            return
        }
        
        MainModel.selectedTicket = ticket
        setSeatCodeForSelectedPassenger(ticket.TrainCode ,seatCodeName: seatTypeId)
        
        self.startLoadingTip("正在提交...")
        
        let postSubmitWindowMessage = {
            self.stopLoadingTip()
            
            if isAuto {
                notificationCenter.post(name: Notification.Name.App.DidAutoSubmit, object: nil)
            }
            else {
                notificationCenter.post(name: Notification.Name.App.DidSubmit, object: nil)
            }
        }
        
        let failHandler = {(error:NSError)->() in
            self.stopLoadingTip()
            
            if error.code == ServiceError.Code.checkUserFailed.rawValue {
                notificationCenter.post(name: Notification.Name.App.DidLogin, object: nil)
            }else{
                self.showTip(translate(error))
            }
        }
        logger.info("\(ticket.TrainCode!) \(ticket.trainDateStr) \(ticket.FromStationName!) -> \(ticket.ToStationName!)  \(seatTypeId) isAuto=\(isAuto)")
        
        let submitParams = SubmitOrderParams(with: ticket,purposeCode: self.ticketType.rawValue)
        Service.sharedInstance.submitFlow(submitParams, success: postSubmitWindowMessage, failure: failHandler)
    }
    
    func clickSubmit(_ sender: NSButton){
        if hasAutoQuery {
            self.stopAutoQuery()
        }
        let selectedRow = leftTicketTable.row(for: sender)
        let ticket = filterQueryResult[selectedRow]
        let seatTypeId = sender.identifier!
        
        self.summitTicket(ticket, seatTypeId: seatTypeId,isAuto: false)
    }
    
    func clickShowTrainDetail(_ sender:NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.maxX
        trainCodeDetailPopover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        
        for queryTicket in ticketQueryResult where queryTicket.TrainCode == sender.title {
            self.trainCodeDetailViewController.ticket = queryTicket
        }
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
// MARK: - Menu Action
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.title.contains("刷新") {
            return true
        }
    
        if filterQueryResult.count <= 0 {
            return false
        }
        
        let selectedRow = leftTicketTable.selectedRow
        let ticket = filterQueryResult[selectedRow]
        //calendar
        if (menuItem.title.contains("日历")) && !ticket.canTicketAdd2Calendar() {
            return false
        }
        
        return true
    }
    
    @IBAction func clickShareInfo(_ sender:AnyObject?) {
        let generalPasteboard = NSPasteboard.general()
        generalPasteboard.clearContents()
        let ticket = filterQueryResult[leftTicketTable.selectedRow]
        let shareInfo = "\(ticket.TrainCode!) \(ticket.FromStationName!)->\(ticket.ToStationName!) \(ticket.trainDateStr) \(ticket.start_time!)->\(ticket.arrive_time!)"
        generalPasteboard.setString(shareInfo, forType:NSStringPboardType)
        
        showTip("车票信息已生成,可复制到其他App")
    }
    
    @IBAction func clickAdd2Calendar(_ sender:AnyObject?){
        let ticket = filterQueryResult[leftTicketTable.selectedRow]
        
        let eventTitle = "预售提醒: \(ticket.TrainCode!) \(ticket.FromStationName!)->\(ticket.ToStationName!)"
        let endDate = ticket.getSaleTime()
        let startDate = endDate.addingTimeInterval(-3600)
        let isSuccess = CalendarManager.sharedInstance.createEvent(title:eventTitle,startDate:startDate,endDate:endDate)

        if !isSuccess {
            self.showTip("添加日历失败,请到 系统偏好设置->安全性与隐私->隐私->日历 允许本程序的访问权限。")
        }
        else {
            self.showTip("添加日历成功。")
        }
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
        
        return matches
    }
}

// MARK: - LunarCalendarViewDelegate
extension TicketQueryViewController: LunarCalendarViewDelegate{
    func createCalenderPopover(){
        let myPopover = NSPopover()
        let cp = LunarCalendarView()
        cp.delegate = self
        cp.date = self.queryDate.dateValue
        cp.selectedDate = self.queryDate.dateValue
        myPopover.contentViewController = cp
        myPopover.appearance = NSAppearance(named: "NSAppearanceNameAqua")
        myPopover.animates = true
        myPopover.behavior = NSPopoverBehavior.transient
        
        self.calendarPopover = myPopover
    }
    
    @IBAction func showCalendar(_ sender: AnyObject){
        self.createCalenderPopover()
        let cellRect = sender.bounds
        self.calendarPopover?.show(relativeTo: cellRect!, of: sender as! NSView, preferredEdge: .maxY)
    }
    
    func didSelectDate(_ selectedDate: Date) {
        self.setQueryDateValue(selectedDate)
        self.calendarPopover?.close()
        
        autoQuery = false
        self.clickQueryTicket(nil)
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
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
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

// MARK: - NSUserNotificationCenterDelegate
extension TicketQueryViewController:NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        self.view.window?.makeKeyAndOrderFront(nil)
//        NSApp.activateIgnoringOtherApps(false)
        center.removeDeliveredNotification(notification)
    }
}
