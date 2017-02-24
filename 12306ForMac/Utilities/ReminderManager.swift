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
    
    func updateAuthorizationStatus()  {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            self.isAccessToEventStoreGranted = true
        case .notDetermined:
            self.eventStore.requestAccess(to: .event, completion: {[unowned self] granted,error in
                DispatchQueue.main.async {
                    self.isAccessToEventStoreGranted = granted
                }
                })
        case .restricted, .denied:
            isAccessToEventStoreGranted = false
        }
    }
    
    func createReminder(_ sender: AnyObject) {
        if !isAccessToEventStoreGranted {
            return
        }
        
        let reminder = EKReminder(eventStore: self.eventStore)
        
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.title = "test"
        
        let date = Date(timeInterval: 5, since: Date())
        let alarm = EKAlarm(absoluteDate: date)
        reminder.addAlarm(alarm)
        
        let date1 = Date(timeInterval: 10, since: Date())
        let alarm1 = EKAlarm(absoluteDate: date1)
        reminder.addAlarm(alarm1)
        
        let date2 = Date(timeInterval: 15, since: Date())
        let alarm2 = EKAlarm(absoluteDate: date2)
        reminder.addAlarm(alarm2)
        
        try! eventStore.save(reminder, commit: true)
    }
}
