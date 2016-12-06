//
//  LunarCalendarView.swift
//  LunarCalendarDemo
//
//  Created by fancymax on 15/12/27.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

protocol LunarCalendarViewDelegate:NSObjectProtocol{
    func didSelectDate(_ selectedDate:Date)
}

class LunarCalendarView:NSViewController{
    
    @IBOutlet weak var calendarTittle: NSTextField!
    
    var backgroundColor:NSColor?
    var textColor:NSColor?
    var selectionColor:NSColor?
    var todayMarkerColor:NSColor?
    var dayMakerColor:NSColor?
    var limitedDays:Double?
    
    weak var delegate:LunarCalendarViewDelegate?
    
    var date:Date?{
        didSet{
            date = self.toUTC(date!)
            
            if !self.isViewLoaded {
                return
            }
            
            self.layoutCalendar()
            self.setCalendarTitle()
        }
    }
    
    var selectedDate:Date?{
        didSet {
            selectedDate = self.toUTC(selectedDate!)
            
            if !self.isViewLoaded {
                return
            }
            
            self.setCellSelectedStatusBy(selectedDate)
        }
    }
    
    fileprivate var dayCells:[[CalendarCell]]?
    fileprivate var dayLabels:[NSTextField]?
    
    static func toUTCDateComponent(_ d:Date) -> DateComponents {
        var cal  = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let dateFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue | NSCalendar.Unit.year.rawValue | NSCalendar.Unit.weekday.rawValue
        return (cal as NSCalendar).components(NSCalendar.Unit(rawValue: dateFlag), from: d)
    }
    
    static func isSameDate(_ d1:Date,d2:Date)->Bool{
        let d1SysTime = LunarCalendarView.toUTCDateComponent(d1)
        let d2SysTime = LunarCalendarView.toUTCDateComponent(d2)
        
        if ((d1SysTime.year == d2SysTime.year)&&(d1SysTime.month == d2SysTime.month)&&(d1SysTime.day == d2SysTime.day))
        {
            return true
        }
        else{
            return false
        }
    }
    
    static func isDate(_ d1:Date,beforeDate d2:Date)->Bool{
        let d1SysTime = LunarCalendarView.toUTCDateComponent(d1)
        let d2SysTime = LunarCalendarView.toUTCDateComponent(d2)
        
        if d1SysTime.year! < d2SysTime.year! {
            return true
        }
        
        if ((d1SysTime.year! == d2SysTime.year!)&&(d1SysTime.month! < d2SysTime.month!)) {
            return true
        }
        
        if ((d1SysTime.year! == d2SysTime.year!)&&(d1SysTime.month! == d2SysTime.month!)&&(d1SysTime.day! < d2SysTime.day!)) {
            return true
        }
        
        return false
    }
    
    fileprivate static let AvailableDays = 60.0
    
    static func getMostAvailableDay() -> Date {
        return Date(timeIntervalSinceNow: (AvailableDays - 1) * 24 * 3600)
    }
    
    static func isDate(_ d1:Date,inLimitDays days:Double)->Bool{
        let limitedDate = Date(timeIntervalSinceNow: days * 24.0 * 3600)
        return LunarCalendarView.isDate(d1, beforeDate: limitedDate)
    }
    
    init(){
        super.init(nibName: "LunarCalendarView", bundle: nil)!
        commonInit()
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        self.backgroundColor = NSColor.white
        self.textColor = NSColor.black
        self.selectionColor = NSColor.red
        self.todayMarkerColor = NSColor.green
        self.dayMakerColor = NSColor.darkGray
        
        self.date = Date()
    }
    
    fileprivate func setCalendarTitle(){
        let components = LunarCalendarView.toUTCDateComponent(self.date!)
        
        let df = DateFormatter()
        let monthName = df.standaloneMonthSymbols[components.month! - 1]
        self.calendarTittle.stringValue = "\(monthName), \(components.year!)"
    }
    
    fileprivate func setCellSelectedStatusBy(_ date: Date?) {
        if self.dayCells == nil {
            return
        }
        for row in 0...5 {
            for col in 0...6{
                let cell = self.dayCells![row][col]
                if ((cell.representedDate != nil)&&(date != nil)){
                    let isSelected = LunarCalendarView.isSameDate(cell.representedDate!, d2: date!)
                    cell.selected = isSelected
                }
                else{
                    cell.selected = false
                }
            }
        }
    }
    
    func layoutCalendar(){
        for row in 0...5 {
            for col in 0...6 {
                let cell = self.dayCells![row][col]
                cell.representedDate = nil
                cell.selected = false
            }
        }
        
        let components = LunarCalendarView.toUTCDateComponent(self.monthDay(1)!)
        
        let firstDay = components.weekday
        let lastDay = lastDayOfTheMonth()
        var beginCol = colForDay(firstDay!)
        var day = 1
        for row in 0...5 {
            for col in beginCol..<7 {
                if day <= lastDay{
                    let cell = self.dayCells![row][col]
                    let d = self.monthDay(day)
                    cell.representedDate = d
                    cell.selected = LunarCalendarView.isSameDate(d!, d2: self.selectedDate!)
                    day += 1
                }
            }
            beginCol = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dayLabels = [NSTextField]()
        for i in 1...7 {
            let _id = "day\(i)"
            let d = self.viewByID(_id) as! NSTextField
            self.dayLabels!.append(d)
        }
        
        self.dayCells = [[CalendarCell]]()
        for _ in 0...5 {
            self.dayCells!.append([CalendarCell]())
        }
        for row in 0...5 {
            for col in 0...6 {
                let i = row * 7 + col + 1
                let _id = "c\(i)"
                let cell = self.viewByID(_id) as! CalendarCell
                cell.target = self
                cell.action = #selector(LunarCalendarView.cellClicked(_:))
                self.dayCells![row].append(cell)
                cell.owner = self
            }
        }
        let df = DateFormatter()
        let days = df.shortWeekdaySymbols!
        for i in 0..<days.count {
            let day = days[i].uppercased()
            let col = colForDay(i + 1)
            let tf = self.dayLabels![col]
            tf.stringValue = day
        }
        
        self.setCalendarTitle()
        
        let bv = self.view as! CalendarBackgroud
        bv.backgroundColor = self.backgroundColor
        self.layoutCalendar()
    }
    
    func viewByID(_ _id:String) -> NSView?{
        for view in self.view.subviews {
            if view.identifier == _id{
                return view
            }
        }
        return nil
    }
    
    func cellClicked(_ sender: NSButton){
        for row in 0...5 {
            for col in 0...6 {
                self.dayCells![row][col].selected = false
            }
        }
        let cell = sender as! CalendarCell
        cell.selected = true
        self.selectedDate = cell.representedDate
        if self.delegate != nil{
            if self.delegate!.responds(to: Selector(("didSelectDate:"))){
                self.delegate!.didSelectDate(self.selectedDate!)
            }
        }
    }
    
    func toUTC(_ d:Date)->Date{
        var cal = Calendar.current
        let unitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue | NSCalendar.Unit.year.rawValue
        let component = (cal as NSCalendar).components(NSCalendar.Unit(rawValue: unitFlag), from: d)
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        return cal.date(from: component)!
    }
    
    func monthDay(_ day: Int)->Date?{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue | NSCalendar.Unit.year.rawValue
        let components = (cal as NSCalendar).components(NSCalendar.Unit(rawValue: unitFlag), from: self.date!)
        var comps = DateComponents()
        comps.day = day
        comps.year = components.year
        comps.month = components.month
        return cal.date(from: comps)
    }
    
    func lastDayOfTheMonth() -> Int{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let daysRange = (cal as NSCalendar).range(of: .day, in: .month, for: self.date!)
        return daysRange.length
    }
    
    func colForDay(_ day:Int)->Int{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let firstWeekday = cal.firstWeekday
        var idx = day - firstWeekday
        if idx < 0 {
            idx = idx + 7
        }
        return idx
    }
    
    func stepMonth(_ dm:Int){
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue | NSCalendar.Unit.year.rawValue
        var components = (cal as NSCalendar).components(NSCalendar.Unit(rawValue: unitFlag), from: self.date!)
        var month = components.month! + dm
        var year = components.year!
        if month > 12 {
            month = 1
            year += 1
        }
        if month < 1 {
            month = 12
            year -= 1
        }
    	components.year = year;
    	components.month = month;
    	self.date = cal.date(from: components)
    }
    
    @IBAction func nextMonth(_ sender: NSButton){
        self.stepMonth(1)
    }
    
    @IBAction func prevMonth(_ sender: NSButton){
        self.stepMonth(-1)
    }
}

class CalendarBackgroud:NSView
{
    var backgroundColor:NSColor?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    fileprivate func commonInit(){
        self.backgroundColor = NSColor.white
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.backgroundColor?.set()
        NSRectFill(self.bounds)
    }
}

class CalendarCell:NSButton
{
    weak var owner:LunarCalendarView!
    
    var representedDate:Date?{
        didSet{
            self.needsDisplay = true
        }
        willSet(newValue){
            if let date = newValue {
                let components = LunarCalendarView.toUTCDateComponent(date)
                self.lunarStr = LunarSolarConverter.Conventer2lunarStr(date)
                self.solarStr = "\(components.day!)"
            }
        }
    }
    
    fileprivate var solarStr:String!
    fileprivate var lunarStr:String!
    
    var selected:Bool = false {
        didSet{
            self.needsDisplay = true
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    fileprivate func commonInit(){
        self.isBordered = false
    }
    
    fileprivate func isToday()->Bool{
        return LunarCalendarView.isSameDate(self.representedDate!, d2: Date())
    }
    
    fileprivate func beforeToday()->Bool{
        return LunarCalendarView.isDate(self.representedDate!, beforeDate: Date())
    }
    
    fileprivate func isInLimitedDate()->Bool{
        var days = LunarCalendarView.AvailableDays
        if self.owner.limitedDays != nil {
            days = self.owner.limitedDays!
        }
        return LunarCalendarView.isDate(self.representedDate!, inLimitDays: days)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if  self.representedDate != nil {
            NSGraphicsContext.saveGraphicsState();
            let bounds = self.bounds
            self.owner.backgroundColor!.set()
            NSRectFill(bounds)
            
            if self.selected {
                var circleRect = NSInsetRect(bounds, 3.5, 3.5)
                circleRect.origin.y += 1
                let bzc = NSBezierPath(ovalIn: circleRect)
                self.owner.selectionColor!.set()
                bzc.fill()
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .center
            
            //today
            if self.isToday(){
                self.owner.todayMarkerColor!.set()
                let bottomLine = NSBezierPath()
                bottomLine.move(to: NSMakePoint(NSMinX(bounds), NSMaxY(bounds)))
                bottomLine.line(to: NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)))
                bottomLine.lineWidth = 4.0
                bottomLine.stroke()
            }
            
            //lunar
            if !self.selected {
                let lunarFont = NSFont(name: self.font!.fontName, size: 8)!
                let attrs = [NSParagraphStyleAttributeName:paragraphStyle,
                    NSFontAttributeName:lunarFont,
                    NSForegroundColorAttributeName:NSColor.gray]
                let size = (self.lunarStr as NSString).size(withAttributes: attrs)
                let r = NSMakeRect(bounds.origin.x,
                    bounds.origin.y + (bounds.size.height - size.height)/2.0 + 12,
                    bounds.size.width, bounds.size.height)
                (self.lunarStr as NSString).draw(in: r, withAttributes: attrs)
                
            }
            
            //solar
            let solarFont = NSFont(name: self.font!.fontName, size: 15)!
            var textColor: NSColor!
            if (self.beforeToday() || (!self.isInLimitedDate())) {
                textColor = NSColor.gray
                self.isEnabled = false
            }
            else {
                textColor = self.owner.textColor
                self.isEnabled = true
            }
            let attrs = [NSParagraphStyleAttributeName:paragraphStyle,
                NSFontAttributeName:solarFont,
                NSForegroundColorAttributeName: textColor]
            let size = (self.solarStr as NSString).size(withAttributes: attrs)
            let r = NSMakeRect(bounds.origin.x,
                bounds.origin.y + (bounds.size.height - size.height)/2.0-1,
                bounds.size.width, bounds.size.height)
            (self.solarStr as NSString).draw(in: r, withAttributes: attrs)
            
            NSGraphicsContext.restoreGraphicsState()
        }
        else {
            self.isEnabled = false
        }
        
    }
    
}
