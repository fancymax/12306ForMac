//
//  ReminderPreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 2017/3/10.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Cocoa
import MASPreferences

class Festival2Reminder: NSObject {
    let date:Date
    let reminderDate:Date
    let name:String
    var shouldReminder = true
    
    private func getDateStrFrom(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var dateStr:String {
        return getDateStrFrom(date: self.date)
    }
    
    var reminderDateStr:String {
        return getDateStrFrom(date: self.reminderDate)
    }
    
    init(name:String,date:Date,reminderDate:Date,shouldReminder:Bool) {
       self.name = name
       self.date = date
       self.reminderDate = reminderDate
        self.shouldReminder = shouldReminder
    }
}

class ReminderPreferenceViewController: NSViewController,MASPreferencesViewController {
    
    struct reminderFestivalKey {
        var monthDayKey:String = ""
        var name:String = ""
        var isLunar = false
    }
    
    private let reminderFestival = [
        //key,name,isLunar
        ["01-01","元旦节",false],
        ["02-14","情人节",false],
        ["05-01","劳动节",false],
        ["05-05","端午节",true],
        ["07-07","七夕节",true],
        ["08-15","中秋节",true],
        ["10-01","国庆节",false],
        ["11-11","光棍节",false],
        ["12-24","平安夜",false]
        ]
    
    @IBOutlet weak var remindAccessLabel: NSTextField!
    @IBOutlet weak var remindAccessInfoButton: InfoButton!
    
    @IBOutlet weak var calendarAccessLabel: NSTextField!
    @IBOutlet weak var calendarAccessInfoButton: InfoButton!
    
    var festivalReminderInfos = [Festival2Reminder]()
    
    var hasAccessGrantedReminder = false {
        didSet {
            if hasAccessGrantedReminder {
                remindAccessLabel.stringValue = "提醒权限☑"
                remindAccessInfoButton.isHidden = true
            }
            else {
                remindAccessLabel.stringValue = "提醒权限☒"
                remindAccessInfoButton.isHidden = false
            }
        }
    }
    
    var hasAccessGrantedCalendar = false {
        didSet {
            if hasAccessGrantedCalendar {
                calendarAccessLabel.stringValue = "日历权限☑"
                calendarAccessInfoButton.isHidden = true
            }
            else {
                calendarAccessLabel.stringValue = "日历权限☒"
                calendarAccessInfoButton.isHidden = false
            }
        }
    }
    
    private func getDateStrFrom(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    override func viewDidLoad() {
        if ReminderManager.sharedInstance.updateAuthorizationStatus() {
            hasAccessGrantedReminder = true
        }
        else {
            hasAccessGrantedReminder = false
        }
        
        if CalendarManager.sharedInstance.updateAuthorizationStatus() {
            hasAccessGrantedCalendar = true
        }
        else {
            hasAccessGrantedCalendar = false
        }
        
        self.festivalReminderInfos = self.GetAllReminderDate()
    }
    
    override var nibName: String? {
        return "ReminderPreferenceViewController"
    }
    
    override var identifier: String!{
        get {
            return "ReminderPreference"
        }
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: "Reminder.png")
    }
    
    var toolbarItemLabel: String! {
        return NSLocalizedString("提醒", comment: "Reminder")
    }
    
    func GetAllReminderDate()->[Festival2Reminder] {
        var ret = [Festival2Reminder]()
        
        let solarCal = Calendar.current
        let solarYear = solarCal.dateComponents([.year], from: Date()).year!
        let lunarCal = Calendar(identifier: Calendar.Identifier.chinese)
        let lunarYear = lunarCal.dateComponents([.year], from: Date()).year!
        
        for i in 0...reminderFestival.count - 1 {
            
            let key = reminderFestival[i][0] as! String
            let name = reminderFestival[i][1] as! String
            let isLunar = reminderFestival[i][2] as! Bool
            
            let monthDay = key.components(separatedBy: "-")
            let m = Int(monthDay[0])!
            let d = Int(monthDay[1])!
            var date:Date
            if !isLunar {
                date = DateComponents(calendar: solarCal,year:solarYear, month: m, day: d).date!
            }
            else {
                date = DateComponents(calendar: lunarCal,year:lunarYear, month: m, day: d).date!
            }
            var reminderDate = date.addingTimeInterval(-3600*24*30)
            
            if LunarCalendarView.isDate(reminderDate, beforeDate: Date()) {
                if !isLunar {
                    date = DateComponents(calendar: solarCal,year:solarYear + 1, month: m, day: d).date!
                }
                else {
                    date = DateComponents(calendar: lunarCal,year:lunarYear + 1, month: m, day: d).date!
                }
                reminderDate = date.addingTimeInterval(-3600*24*30)
            }
            
            ret.append(Festival2Reminder(name:name,date:date,reminderDate:reminderDate,shouldReminder:true))
        }
        
        return ret
    }
    
    func showTip(_ tip:String){
        DJTipHUD.showStatus(tip, from: self.view)
    }
    
    @IBAction func clickAdd2Calendar(_ sender:AnyObject?){
        
        var isSuccess:Bool?
        for item in festivalReminderInfos where item.shouldReminder {
            let eventTitle = "\(item.name) 火车票 预售提醒(明天预售)"
            let startDate = item.reminderDate
            let endDate = startDate.addingTimeInterval(24*3600)
            isSuccess = CalendarManager.sharedInstance.createEvent(title:eventTitle,startDate:startDate,endDate:endDate)
            if !isSuccess! {
                break
            }
        }
        
        if isSuccess == nil {
            return
        }
        
        if !isSuccess! {
            self.showTip("添加日历失败,请到 系统偏好设置->安全性与隐私->隐私->日历 允许本程序的访问权限。")
        }
        else {
            self.showTip("添加日历成功。")
        }
    }
}

extension ReminderPreferenceViewController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.festivalReminderInfos.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.festivalReminderInfos[row]
    }
}
