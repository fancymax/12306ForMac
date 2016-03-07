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
    
    weak var delegate:LunarCalendarViewDelegate?
    private var _date:NSDate?
    var date:NSDate?{
        get{
            return _date
        }
        set{
            _date = self.toUTC(newValue!)
            if !self.viewLoaded {
                return
            }
            
            self.layoutCalendar()
            self.setCalendarTitle()
        }
    }
    
    private var _selectedDate:NSDate?
    var selectedDate:NSDate?{
        get{
            return _selectedDate
        }
        set{
            _selectedDate = self.toUTC(newValue!)
            
            if !self.viewLoaded {
                return
            }
            
            for row in 0...5 {
                for col in 0...6{
                    let cell = self.dayCells![row][col]
                    if ((cell.representedDate != nil)&&(_selectedDate != nil)){
                        let isSelected = LunarCalendarView.isSameDate(cell.representedDate!, d2: _selectedDate!)
                        cell.selected = isSelected
                    }
                    else{
                        cell.selected = false
                    }
                }
            }
            
        }
    }
    
    private var dayCells:[[CalendarCell]]?
    private var dayLabels:[NSTextField]?
    
    static func isSameDate(d1:NSDate,d2:NSDate)->Bool{
        let cal  = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue
        var components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: d1)
        let ry = components.year
        let rm = components.month
        let rd = components.day
        
        components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: d2)
        let ty = components.year
        let tm = components.month
        let td = components.day
        
        if ((ry == ty)&&(rm == tm)&&(rd == td))
        {
            return true
        }
        else{
            return false
        }
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
        self.dayCells = [[CalendarCell]]()
        for _ in 0...5 {
            self.dayCells!.append([CalendarCell]())
        }
        
        self._date = NSDate()
    }
    
    private func setCalendarTitle(){
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue
        let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: self._date!)
        let month = components.month
        let year = components.year
        
        let df = NSDateFormatter()
        let monthName = df.standaloneMonthSymbols[month - 1]
        self.calendarTittle.stringValue = "\(monthName), \(year)"
    }
    
    func layoutCalendar(){
        for row in 0...5 {
            for col in 0...6 {
                let cell = self.dayCells![row][col]
                cell.representedDate = nil
                cell.selected = false
            }
        }
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let unitFlag = NSCalendarUnit.Weekday.rawValue
        let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: self.monthDay(1)!)
        let firstDay = components.weekday
        let lastDay = lastDayOfTheMonth()
        var col = colForDay(firstDay)
        var day = 1
        for row in 0...5{
            for ; col<7; col+=1 {
                if day <= lastDay{
                    let cell = self.dayCells![row][col]
                    let d = self.monthDay(day)
                    cell.representedDate = d
                    cell.selected = LunarCalendarView.isSameDate(d!, d2: self._selectedDate!)
                    day += 1
                }
            }
            col = 0
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
        for row in 0...5 {
            for col in 0...6 {
                let i = row * 7 + col + 1
                let _id = "c\(i)"
                let cell = self.viewByID(_id) as! CalendarCell
                cell.target = self
                cell.action = Selector("cellClicked:")
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
        self._selectedDate = cell.representedDate
        if self.delegate != nil{
            if self.delegate!.respondsToSelector(Selector("didSelectDate:")){
                self.delegate!.didSelectDate(self._selectedDate!)
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
        let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: self._date!)
        let comps = NSDateComponents()
        comps.day = day
        comps.year = components.year
        comps.month = components.month
        return cal.dateFromComponents(comps)
    }
    
    func lastDayOfTheMonth() -> Int{
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let daysRange = cal.rangeOfUnit(.Day, inUnit: .Month, forDate: self._date!)
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
        let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: self._date!)
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
        self.stepMonth(1)
    }
    
    @IBAction func prevMonth(sender: NSButton){
        self.stepMonth(-1)
    }
}

class CalendarBackgroud:NSView
{
    var backgroundColor:NSColor?
    
    required init?(coder: NSCoder) {
        //todo??
        super.init(coder: coder)
        self.commonInit()
    }
    
    required override init(frame frameRect: NSRect) {
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
    weak var owner:LunarCalendarView?
    private var _representedDate:NSDate?
    var representedDate:NSDate?{
        get{
            return _representedDate
        }
        set{
            _representedDate = newValue
            if _representedDate != nil{
                let cal = NSCalendar.currentCalendar()
                cal.timeZone = NSTimeZone(abbreviation: "UTC")!
                let unitFlag = NSCalendarUnit.Day.rawValue | NSCalendarUnit.Month.rawValue | NSCalendarUnit.Year.rawValue
                let components = cal.components(NSCalendarUnit(rawValue: unitFlag), fromDate: _representedDate!)
                self.lunarStr = LunarSolarConverter.Conventer2lunarStr(_representedDate!)
                self.solarStr = "\(components.day)"
            }
            else{
                self.lunarStr = ""
                self.solarStr = ""
            }
            self.needsDisplay = true
        }
    }
    private var solarStr:String!
    private var lunarStr:String!
    private var _selected:Bool = false
    var selected:Bool{
        get{
            return _selected
        }
        set{
            _selected = newValue
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
        self._representedDate = nil
    }
    
    private func isToday()->Bool{
        if(self._representedDate != nil){
            return LunarCalendarView.isSameDate(self._representedDate!, d2: NSDate())
        }
        else{
            return false
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if self.owner != nil{
            NSGraphicsContext.saveGraphicsState();
            let bounds = self.bounds
            self.owner?.backgroundColor!.set()
            NSRectFill(bounds)
            
            if self._representedDate != nil{
                if self._selected {
                    var circleRect = NSInsetRect(bounds, 3.5, 3.5)
                    circleRect.origin.y += 1
                    let bzc = NSBezierPath(ovalInRect: circleRect)
                    self.owner?.selectionColor!.set()
                    bzc.fill()
                }
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .ByWordWrapping
                paragraphStyle.alignment = .Center
                
                //solar
                let solarFont = NSFont(name: self.font!.fontName, size: 15)!
                let attrs = [NSParagraphStyleAttributeName:paragraphStyle,
                    NSFontAttributeName:solarFont,
                    NSForegroundColorAttributeName:self.owner!.textColor!]
                let size = (self.solarStr as NSString).sizeWithAttributes(attrs)
                let r = NSMakeRect(bounds.origin.x,
                    bounds.origin.y + (bounds.size.height - size.height)/2.0-1,
                    bounds.size.width, bounds.size.height)
                (self.solarStr as NSString).drawInRect(r, withAttributes: attrs)
                
                //today
                if self.isToday(){
                    self.owner?.todayMarkerColor!.set()
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
            }
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    
}
