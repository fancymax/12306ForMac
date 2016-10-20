//
//  AppDelegate.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//
import Cocoa

var APP_LOG_PATH = ""
var APP_LOG_DIRECTORY = ""

let logger: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.defaultInstance()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyyMMddhhmm"
    let dateStr = dateFormatter.stringFromDate(NSDate())
    
    let bundleId = NSBundle.mainBundle().bundleIdentifier!
    let fileName = "\(bundleId).\(dateStr).txt"

    APP_LOG_DIRECTORY = "\(NSHomeDirectory())/Library/Logs/\(bundleId)/"
    APP_LOG_PATH = "\(APP_LOG_DIRECTORY)/\(fileName)"
    
    let isExistDirectory:Bool = NSFileManager.defaultManager().fileExistsAtPath(APP_LOG_DIRECTORY, isDirectory: nil)
    if !isExistDirectory {
        do{
            try NSFileManager.defaultManager().createDirectoryAtPath(APP_LOG_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("createDirectoryAtPath fail,can't log")
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
    log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: APP_LOG_PATH)
    
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
        
        let mainController = MainWindowController(windowNibName: "MainWindowController")
        mainController.showWindow(self)
        
        self.mainController = mainController
        
        logger.debug("application start")
    }
    
    @IBAction func openDebugFile(sender:AnyObject) {
        NSWorkspace.sharedWorkspace().openFile(APP_LOG_PATH)
    }
    
    @IBAction func openDebugDirectory(sender:AnyObject) {
        NSWorkspace.sharedWorkspace().openFile(APP_LOG_DIRECTORY)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender:NSApplication)->Bool {
        return true
    }

}

