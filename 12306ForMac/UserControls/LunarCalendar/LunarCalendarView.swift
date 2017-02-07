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
    
// MARK: - Static
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
    
//MARK: - Public Properties
    weak var delegate:LunarCalendarViewDelegate?
    
    var date:Date?{
        didSet{
            date = self.toUTC(date!)
            
            if !self.isViewLoaded {
                return
            }
            
            self.layoutCalendar()
            self.setMonthYearTitle()
        }
    }
    
    var selectedDate:Date?{
        didSet {
            selectedDate = self.toUTC(selectedDate!)
            
            if !self.isViewLoaded {
                return
            }
        }
    }
    
//MARK: - IBOutlet&&IBAction
    @IBOutlet weak var calendarTittle: NSTextField!
    
    @IBAction func clickNextMonth(_ sender: NSButton){
        self.stepMonth(1)
    }
    
    @IBAction func clickPrevMonth(_ sender: NSButton){
        self.stepMonth(-1)
    }
    
//MARK: - fileprivate
    fileprivate var backgroundColor:NSColor?
    fileprivate var textColor:NSColor?
    fileprivate var selectionColor:NSColor?
    fileprivate var todayMarkerColor:NSColor?
    fileprivate var dayMakerColor:NSColor?
    fileprivate var dayCells:[[CalendarCell]]!
    fileprivate var dayLabels:[NSTextField]!
    
    init(){
        super.init(nibName: "LunarCalendarView", bundle: nil)!
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        self.backgroundColor = NSColor.white
        self.textColor = NSColor.black
        self.selectionColor = NSColor.red
        self.todayMarkerColor = NSColor.green
        self.dayMakerColor = NSColor.darkGray
        
        self.date = Date()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCalendarBackground()
        self.setWeekDayLabels()
        self.setMonthDayCell()
        
        self.setMonthYearTitle()
        self.layoutCalendar()
    }
    
    func cellClicked(_ sender: NSButton){
        let cell = sender as! CalendarCell
        if !cell.multiSelected {
            for row in 0...5 {
                for col in 0...6 {
                    self.dayCells[row][col].selected = false
                }
            }
            
            cell.selected = true
            self.selectedDate = cell.representedDate
            if self.delegate != nil{
                if self.delegate!.responds(to: Selector(("didSelectDate:"))){
                    self.delegate!.didSelectDate(self.selectedDate!)
                }
            }
        }
        else {
            cell.selected = !cell.selected
        }
    }
    
    private func setMonthYearTitle(){
        let components = LunarCalendarView.toUTCDateComponent(self.date!)
        
        let df = DateFormatter()
        let monthName = df.standaloneMonthSymbols[components.month! - 1]
        self.calendarTittle.stringValue = "\(monthName), \(components.year!)"
    }
    
    private func setCalendarBackground() {
        let bv = self.view as! CalendarBackgroud
        bv.backgroundColor = self.backgroundColor
    }
    
    private func setWeekDayLabels(){
        self.dayLabels = [NSTextField]()
        for i in 1...7 {
            let _id = "day\(i)"
            let d = self.viewByID(_id) as! NSTextField
            self.dayLabels.append(d)
        }
        
        let dateFormatter = DateFormatter()
        let days = dateFormatter.shortWeekdaySymbols!
        for i in 0..<days.count {
            let day = days[i].uppercased()
            let col = colForDay(i + 1)
            self.dayLabels[col].stringValue = day
        }
    }
    
    private func setMonthDayCell() {
        print("setMonthDayCell")
        
        self.dayCells = [[CalendarCell]]()
        for _ in 0...5 {
            self.dayCells.append([CalendarCell]())
        }
        for row in 0...5 {
            for col in 0...6 {
                let i = row * 7 + col + 1
                let _id = "c\(i)"
                let cell = self.viewByID(_id) as! CalendarCell
                cell.target = self
                cell.action = #selector(LunarCalendarView.cellClicked(_:))
                self.dayCells[row].append(cell)
                cell.owner = self
            }
        }
    }
    
    private func layoutCalendar(){
        //reset all date cell value
        for row in 0...5 {
            for col in 0...6 {
                let cell = self.dayCells[row][col]
                cell.representedDate = nil
                cell.selected = false
            }
        }

        let components = LunarCalendarView.toUTCDateComponent(self.monthDay(1)!)
        //layout Calendar of one month
        let firstDay = components.weekday
        let lastDay = lastDayOfTheMonth()
        var beginCol = colForDay(firstDay!)
        var day = 1
        for row in 0...5 {
            for col in beginCol..<7 {
                if day <= lastDay{
                    let cell = self.dayCells[row][col]
                    let d = self.monthDay(day)
                    cell.representedDate = d
                    cell.selected = LunarCalendarView.isSameDate(d!, d2: self.selectedDate!)
                    day += 1
                }
            }
            beginCol = 0
        }
    }
    
    private func viewByID(_ _id:String) -> NSView?{
        for view in self.view.subviews {
            if view.identifier == _id{
                return view
            }
        }
        return nil
    }
    
    private func toUTC(_ d:Date)->Date{
        var cal = Calendar.current
        let unitFlag = NSCalendar.Unit.day.rawValue | NSCalendar.Unit.month.rawValue | NSCalendar.Unit.year.rawValue
        let component = (cal as NSCalendar).components(NSCalendar.Unit(rawValue: unitFlag), from: d)
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        return cal.date(from: component)!
    }
    
    private func monthDay(_ day: Int)->Date?{
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
    
    private func lastDayOfTheMonth() -> Int{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let daysRange = (cal as NSCalendar).range(of: .day, in: .month, for: self.date!)
        return daysRange.length
    }
    
    private func colForDay(_ day:Int)->Int{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let firstWeekday = cal.firstWeekday
        var idx = day - firstWeekday
        if idx < 0 {
            idx = idx + 7
        }
        return idx
    }
    
    private func stepMonth(_ dm:Int){
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
}

class CalendarBackgroud:NSView
{
    fileprivate var backgroundColor:NSColor?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.backgroundColor?.set()
        NSRectFill(self.bounds)
    }
    
    private func commonInit(){
        self.backgroundColor = NSColor.white
    }
}

class CalendarCell:NSButton
{
    fileprivate weak var owner:LunarCalendarView!
    
    fileprivate var representedDate:Date?{
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
    
    fileprivate var selected:Bool = false {
        didSet{
            self.needsDisplay = true
        }
    }
    
    fileprivate var multiSelected:Bool = false
    
    private var solarStr:String!
    private var lunarStr:String!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.control) {
            multiSelected = true
        }
        else {
            multiSelected = false
        }
        super.mouseDown(with: event)
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
    
    private func commonInit(){
        self.isBordered = false
    }
    
    private func isToday()->Bool{
        return LunarCalendarView.isSameDate(self.representedDate!, d2: Date())
    }
    
    private func beforeToday()->Bool{
        return LunarCalendarView.isDate(self.representedDate!, beforeDate: Date())
    }
    
    private func isInLimitedDate()->Bool{
        return LunarCalendarView.isDate(self.representedDate!, inLimitDays: LunarCalendarView.AvailableDays)
    }
}
