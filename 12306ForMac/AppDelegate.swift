//
//  AppDelegate.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//
import Fabric
import Crashlytics

import Cocoa

let logger: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.defaultInstance()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyyMMddhhmm"
    let dateStr = dateFormatter.stringFromDate(NSDate())
    
    let bundleId = NSBundle.mainBundle().bundleIdentifier!
    let fileName = "\(bundleId).\(dateStr).txt"

    let logDirectory = "\(NSHomeDirectory())/Library/Logs/\(bundleId)/"
    let logPath = "\(logDirectory)/\(fileName)"
    
    let isExistDirectory:Bool = NSFileManager.defaultManager().fileExistsAtPath(logDirectory, isDirectory: nil)
    if !isExistDirectory {
        do{
            try NSFileManager.defaultManager().createDirectoryAtPath(logDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("Creat 12306ForMac log fail")
        }
    }
    
    log.xcodeColors = [
        .Verbose: .lightGrey,
        .Debug: .darkGrey,
        .Info: .darkGreen,
        .Warning: .orange,
        .Error: XCGLogger.XcodeColor(fg: NSColor.redColor(), bg: NSColor.whiteColor()), // Optionally use an NSColor
        .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
    ]
    log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: logPath)
    
    return log
}()

let DidSendLoginMessageNotification = "com.12306.DidSendLoginMessageNotification"
let DidSendLogoutMessageNotification = "com.12306.DidSendLogoutMessageNotification"
let DidSendSubmitMessageNotification = "com.12306.DidSendSubmitMessageNotification"
let DidSendTrainFilterMessageNotification = "com.12306.DidSendTrainFilterMessageNotification"
let DidSendCheckPassengerMessageNotification = "com.12306.DidSendCheckPassengerMessageNotification"
let CanFilterTrainNotification = "com.12306.CanFilterTrainNotification"
let DidSendAutoLoginMessageNotification = "com.12306.DidSendAutoLoginMessageNotification"
let DidSendAutoSubmitMessageNotification = "com.12306.DidSendAutoSubmitMessageNotification"

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {

    var mainController:MainWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
    NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions":NSNumber(bool: true)])
        
        Fabric.with([Crashlytics.self])
        
        let mainController = MainWindowController(windowNibName: "MainWindowController")
        mainController.showWindow(self)
        
        self.mainController = mainController
        
        logger.debug("application start")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender:NSApplication)->Bool {
        return true
    }

}

