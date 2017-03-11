//
//  ReminderManager.swift
//  12306ForMac
//
//  Created by fancymax on 2/24/2017.
//  Copyright © 2017年 fancy. All rights reserved.
//

import Foundation
import EventKit

class ReminderManager: NSObject {
    
    private let eventStore:EKEventStore
    private var isAccessToEventStoreGranted:Bool
    
    fileprivate static let sharedManager = ReminderManager()
    class var sharedInstance: ReminderManager {
        return sharedManager
    }
    
    private override init () {
        isAccessToEventStoreGranted = false
        eventStore = EKEventStore()
    }
    
    @discardableResult
    func updateAuthorizationStatus()->Bool  {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            self.isAccessToEventStoreGranted = true
            return true
        case .notDetermined:
            self.eventStore.requestAccess(to: .reminder, completion: {[unowned self] granted,error in
                DispatchQueue.main.async {
                    self.isAccessToEventStoreGranted = granted
                }
                })
            return false
        case .restricted, .denied:
            isAccessToEventStoreGranted = false
            return false
        }
    }
    
    func createReminder(_ title:String, startDate:Date) {
        if !isAccessToEventStoreGranted {
            return
        }
        
        let reminder = EKReminder(eventStore: self.eventStore)
        
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.title = title
        
        var date = Date(timeInterval: 5, since: Date())
        var alarm = EKAlarm(absoluteDate: date)
        reminder.addAlarm(alarm)
        
        date = Date(timeInterval: 10, since: Date())
        alarm = EKAlarm(absoluteDate: date)
        reminder.addAlarm(alarm)
        
        date = Date(timeInterval: 15, since: Date())
        alarm = EKAlarm(absoluteDate: date)
        reminder.addAlarm(alarm)
        
        try! eventStore.save(reminder, commit: true)
    }
}
