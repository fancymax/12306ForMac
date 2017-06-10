//
//  AppDelegate.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//
import Cocoa
import XCGLogger

var APP_LOG_PATH = ""
var APP_LOG_DIRECTORY = ""

let logger: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
    
    let bundleId = Bundle.main.bundleIdentifier!
    let fileName = "\(bundleId).txt"

    APP_LOG_DIRECTORY = "\(NSHomeDirectory())/Library/Logs/\(bundleId)/"
    APP_LOG_PATH = "\(APP_LOG_DIRECTORY)/\(fileName)"
    
    let isExistDirectory:Bool = FileManager.default.fileExists(atPath: APP_LOG_DIRECTORY, isDirectory: nil)
    if !isExistDirectory {
        do{
            try FileManager.default.createDirectory(atPath: APP_LOG_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("createDirectoryAtPath fail,can't log")
        }
    }
    
    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
    
    // Optionally set some configuration options
    systemDestination.outputLevel = .info
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = false
    systemDestination.showLevel = false
    systemDestination.showFileName = false
    systemDestination.showLineNumber = false
    systemDestination.showDate = false
    log.add(destination: systemDestination)
    
    let autoRotatingFileDestination = AutoRotatingFileDestination(writeToFile:APP_LOG_PATH)
    autoRotatingFileDestination.targetMaxLogFiles = 10
    
    autoRotatingFileDestination.outputLevel = .info
    autoRotatingFileDestination.showLogIdentifier = false
    autoRotatingFileDestination.showFunctionName = false
    autoRotatingFileDestination.showLevel = false
    autoRotatingFileDestination.showFileName = false
    autoRotatingFileDestination.showLineNumber = false
    autoRotatingFileDestination.showDate = true
    log.add(destination:autoRotatingFileDestination)
    
    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()
    
    
    return log
}()

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {

    var mainController:MainWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainController = MainWindowController(windowNibName: "MainWindowController")
        mainController.showWindow(self)
        
        self.mainController = mainController
        logger.info("Application start")
        logger.info("dama = \(AdvancedPreferenceManager.sharedInstance.isUseDama)")
    }
    
    @IBAction func openDebugFile(_ sender:AnyObject) {
        NSWorkspace.shared().openFile(APP_LOG_PATH)
    }
    
    @IBAction func openDebugDirectory(_ sender:AnyObject) {
        NSWorkspace.shared().openFile(APP_LOG_DIRECTORY)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication)->Bool {
        return true
    }
    
//    func applicationWillResignActive(_ notification: Notification) {
//        print("applicationWillResignActive")
//    }
//    
//    func applicationWillBecomeActive(_ notification: Notification) {
//        print("applicationWillBecomeActive")
//    }

}

