//
//  LunarCalendarView.swift
//  LunarCalendarDemo
//
//  Created by fancymax on 15/12/27.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

protocol LunarCalendarViewDelegate:NSObjectProtocol{
    func didSelectDate(selectedDate:NSDate)
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
    
    var date:NSDate?{
        didSet{
            date = self.toUTC(date!)
            
            if !self.viewLoaded {
                return
            }
            
            self.layoutCalendar()
            self.setCalendarTitle()
        }
    }
    
    var selectedDate:NSDate?{
        didSet {
            selectedDate = self.toUTC(selectedDate!)
            
            if !self.viewLoaded {
                return
            }
            
            self.setCellSelectedStatusBy(selectedDate)
        }
    }
    
    private var dayCells:[[CalendarCell]]?
    private var dayLabels:[NSTextField]?
    
    static func toUTCDateComponent(d:NSDate) -> NSDateComponents {
        let cal  = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let dateFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue | NSCalendarUnit.Weekday.rawValue
        return cal.components(NSCalendarUnit(rawValue: dateFlag), fromDate: d)
    }
    
    static func isSameDate(d1:NSDate,d2:NSDate)->Bool{
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
    
    static func isDate(d1:NSDate,beforeDate d2:NSDate)->Bool{
        let d1SysTime = LunarCalendarView.toUTCDateComponent(d1)
        let d2SysTime = LunarCalendarView.toUTCDateComponent(d2)
        
        if d1SysTime.year < d2SysTime.year {
            return true
        }
        
        if ((d1SysTime.year == d2SysTime.year)&&(d1SysTime.month < d2SysTime.month)) {
            return true
        }
        
        if ((d1SysTime.year == d2SysTime.year)&&(d1SysTime.month == d2SysTime.month)&&(d1SysTime.day < d2SysTime.day)) {
            return true
        }
        
        return false
    }
    
    static func isDate(d1:NSDate,inLimitDays days:Double)->Bool{
        let limitedDate = NSDate(timeIntervalSinceNow: days * 24.0 * 3600)
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
        self.backgroundColor = NSColor.whiteColor()
        self.textColor = NSColor.blackColor()
        self.selectionColor = NSColor.redColor()
        self.todayMarkerColor = NSColor.greenColor()
        self.dayMakerColor = NSColor.darkGrayColor()
        
        self.date = NSDate()
    }
    
    private func setCalendarTitle(){
        let components = LunarCalendarView.toUTCDateComponent(self.date!)
        
        let df = NSDateFormatter()
        let monthName = df.standaloneMonthSymbols[components.month - 1]
        self.calendarTittle.stringValue = "\(monthName), \(components.year)"
    }
    
    private func setCellSelectedStatusBy(date: NSDate?) {
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
        var beginCol = colForDay(firstDay)
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
        let df = NSDateFormatter()
        let days = df.shortWeekdaySymbols
        for i in 0..<days.count {
            let day = days[i].uppercaseString
            let col = colForDay(i + 1)
            let tf = self.dayLabels![col]
            tf.stringValue = day
        }
        
        self.setCalendarTitle()
        
        let bv = self.view as! CalendarBackgroud
        bv.backgroundColor = self.backgroundColor
        self.layoutCalendar()
    }
    
    func viewByID(_id:String) -> NSView?{
        for view in self.view.subviews {
            if view.identifier == _id{
                return view
            }
        }
        return nil
    }
    
    func cellClicked(sender: NSButton){
        for row in 0...5 {
            for col in 0...6 {
                self.dayCells![row][col].selected = false
            }
        }
        let cell = sender as! CalendarCell
        cell.selected = true
        self.selectedDate = cell.representedDate
        if self.delegate != nil{
            if self.delegate!.respondsToSelector(Selector("didSelectDate:")){
                self.delegate!.didSelectDate(self.selectedDate!)
            }
        }
    }
    
    func toUTC(d:NSDate)->NSDate{
        let cal = NSCalendar.currentCalendar()
        let unitFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue
        let component = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: d)
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        return cal.dateFromComponents(component)!
    }
    
    func monthDay(day: Int)->NSDate?{
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue
        let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: self.date!)
        let comps = NSDateComponents()
        comps.day = day
        comps.year = components.year
        comps.month = components.month
        return cal.dateFromComponents(comps)
    }
    
    func lastDayOfTheMonth() -> Int{
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let daysRange = cal.rangeOfUnit(.Day, inUnit: .Month, forDate: self.date!)
        return daysRange.length
    }
    
    func colForDay(day:Int)->Int{
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let firstWeekday = cal.firstWeekday
        var idx = day - firstWeekday
        if idx < 0 {
            idx = idx + 7
        }
        return idx
    }
    
    func stepMonth(dm:Int){
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue
        let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: self.date!)
        var month = components.month + dm
        var year = components.year
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
    	self.date = cal.dateFromComponents(components)
    }
    
    @IBAction func nextMonth(sender: NSButton){
        let currentSysTime = LunarCalendarView.toUTCDateComponent(NSDate())
        let selectSysTime = LunarCalendarView.toUTCDateComponent(self.date!)
        var step = 2
        if currentSysTime.month < 3 || currentSysTime.month > 10 {
            step = 3
            
        }
        if selectSysTime.month < currentSysTime.month + step {
            self.stepMonth(1)
        }
    }
    
    @IBAction func prevMonth(sender: NSButton){
        let currentSysTime = LunarCalendarView.toUTCDateComponent(NSDate())
        let selectSysTime = LunarCalendarView.toUTCDateComponent(self.date!)
        if selectSysTime.month > currentSysTime.month {
            self.stepMonth(-1)
        }
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
    
    private func commonInit(){
        self.backgroundColor = NSColor.whiteColor()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        self.backgroundColor?.set()
        NSRectFill(self.bounds)
    }
}

class CalendarCell:NSButton
{
    weak var owner:LunarCalendarView!
    
    var representedDate:NSDate?{
        didSet{
            self.needsDisplay = true
        }
        willSet(newValue){
            if let date = newValue {
                let components = LunarCalendarView.toUTCDateComponent(date)
                self.lunarStr = LunarSolarConverter.Conventer2lunarStr(date)
                self.solarStr = "\(components.day)"
            }
        }
    }
    
    private var solarStr:String!
    private var lunarStr:String!
    
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
    
    private func commonInit(){
        self.bordered = false
    }
    
    private func isToday()->Bool{
        return LunarCalendarView.isSameDate(self.representedDate!, d2: NSDate())
    }
    
    private func beforeToday()->Bool{
        return LunarCalendarView.isDate(self.representedDate!, beforeDate: NSDate())
    }
    
    private func isInLimitedDate()->Bool{
        var days = 60.0
        if self.owner.limitedDays != nil {
            days = self.owner.limitedDays!
        }
        return LunarCalendarView.isDate(self.representedDate!, inLimitDays: days)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if  self.representedDate != nil {
            NSGraphicsContext.saveGraphicsState();
            let bounds = self.bounds
            self.owner.backgroundColor!.set()
            NSRectFill(bounds)
            
            if self.selected {
                var circleRect = NSInsetRect(bounds, 3.5, 3.5)
                circleRect.origin.y += 1
                let bzc = NSBezierPath(ovalInRect: circleRect)
                self.owner.selectionColor!.set()
                bzc.fill()
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            paragraphStyle.alignment = .Center
            
            //today
            if self.isToday(){
                self.owner.todayMarkerColor!.set()
                let bottomLine = NSBezierPath()
                bottomLine.moveToPoint(NSMakePoint(NSMinX(bounds), NSMaxY(bounds)))
                bottomLine.lineToPoint(NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)))
                bottomLine.lineWidth = 4.0
                bottomLine.stroke()
            }
            
            //lunar
            if !self.selected {
                let lunarFont = NSFont(name: self.font!.fontName, size: 8)!
                let attrs = [NSParagraphStyleAttributeName:paragraphStyle,
                    NSFontAttributeName:lunarFont,
                    NSForegroundColorAttributeName:NSColor.grayColor()]
                let size = (self.lunarStr as NSString).sizeWithAttributes(attrs)
                let r = NSMakeRect(bounds.origin.x,
                    bounds.origin.y + (bounds.size.height - size.height)/2.0 + 12,
                    bounds.size.width, bounds.size.height)
                (self.lunarStr as NSString).drawInRect(r, withAttributes: attrs)
                
            }
            
            //solar
            let solarFont = NSFont(name: self.font!.fontName, size: 15)!
            var textColor: NSColor!
            if (self.beforeToday() || (!self.isInLimitedDate())) {
                textColor = NSColor.grayColor()
                self.enabled = false
            }
            else {
                textColor = self.owner.textColor
                self.enabled = true
            }
            let attrs = [NSParagraphStyleAttributeName:paragraphStyle,
                NSFontAttributeName:solarFont,
                NSForegroundColorAttributeName: textColor]
            let size = (self.solarStr as NSString).sizeWithAttributes(attrs)
            let r = NSMakeRect(bounds.origin.x,
                bounds.origin.y + (bounds.size.height - size.height)/2.0-1,
                bounds.size.width, bounds.size.height)
            (self.solarStr as NSString).drawInRect(r, withAttributes: attrs)
            
            NSGraphicsContext.restoreGraphicsState()
        }
        else {
            self.enabled = false
        }
        
    }
    
}
