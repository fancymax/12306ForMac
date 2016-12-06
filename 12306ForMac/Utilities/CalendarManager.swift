//
//  CalendarManager.swift
//  12306ForMac
//
//  Created by fancymax on 2016/12/5.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import EventKit

class CalendarManager:NSObject {
    private let eventStore:EKEventStore
    private var isAccessToEventStoreGranted:Bool
    
    fileprivate static let sharedManager = CalendarManager()
    class var sharedInstance: CalendarManager {
        return sharedManager
    }
    
    fileprivate override init () {
        isAccessToEventStoreGranted = false
        eventStore = EKEventStore()
    }
    
    private func createCalendar() {
        if !isAccessToEventStoreGranted {
            return
        }
        var shouldCreateCalendar = false
        if let calendarId = UserDefaults.standard.string(forKey: "calendarId") {
            let calendar = eventStore.calendar(withIdentifier: calendarId)
            
            if calendar == nil {
                shouldCreateCalendar = true
            }
        }
        else {
            shouldCreateCalendar = true
        }
        if !shouldCreateCalendar {
            return
        }
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "12306ForMac"
        calendar.color = NSColor.gray
        calendar.source = eventStore.defaultCalendarForNewEvents.source
        do {
            try self.eventStore.saveCalendar(calendar, commit: true)
            logger.info("calendarId = \(calendar.calendarIdentifier)")
            UserDefaults.standard.set(calendar.calendarIdentifier, forKey: "calendarId")
        }
        catch {
            logger.error(error)
        }
    }
    
    func updateAuthorizationStatus()  {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            self.isAccessToEventStoreGranted = true
            self.createCalendar()
        case .notDetermined:
            self.eventStore.requestAccess(to: .event, completion: {[unowned self] granted,error in
                DispatchQueue.main.async {
                    self.isAccessToEventStoreGranted = granted
                    self.createCalendar()
                }
                })
        case .restricted, .denied:
            isAccessToEventStoreGranted = false
        }
    }
    
    func createEvent(title:String, startDate:Date, endDate:Date)->Bool {
        if !isAccessToEventStoreGranted {
            return false
        }
        
        let createEventHandler = {(calendar:EKCalendar) -> () in
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = calendar
            do {
                try self.eventStore.save(event, span: .thisEvent, commit: true)
            } catch {
                logger.error(error)
            }
        }
        
        if let calendarId = UserDefaults.standard.string(forKey: "calendarId") {
            if let calendar = eventStore.calendar(withIdentifier: calendarId) {
                createEventHandler(calendar)
            }
            else {
                logger.error("Calendar = nil,create")
                self.createCalendar()
                
                if let calendarId = UserDefaults.standard.string(forKey: "calendarId") {
                    if let calendar = eventStore.calendar(withIdentifier: calendarId) {
                        createEventHandler(calendar)
                    }
                    else{
                        logger.error("Calendar = nil,again")
                    }
                }
            }
        }
        return true
    }
    
}

