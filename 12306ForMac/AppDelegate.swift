//
//  AppDelegate.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//
import Fabric
import Crashlytics
import XCGLogger
import Cocoa

let logger: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.default
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddhhmm"
    let dateStr = dateFormatter.string(from: Date())
    
    let bundleId = Bundle.main.bundleIdentifier!
    let fileName = "\(bundleId).\(dateStr).txt"

    let logDirectory = "\(NSHomeDirectory())/Library/Logs/\(bundleId)/"
    let logPath = "\(logDirectory)/\(fileName)"
    
    let isExistDirectory:Bool = FileManager.default.fileExists(atPath: logDirectory, isDirectory: nil)
    if !isExistDirectory {
        do{
            try FileManager.default.createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Creat 12306ForMac log fail")
        }
    }
    

    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.appleSystemLogDestination")
    
    // Optionally set some configuration options
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    
    // Add colour to the console destination.
    // - Note: You need the XcodeColors Plug-in https://github.com/robbiehanson/XcodeColors installed in Xcode
    // - to see colours in the Xcode console. Plug-ins have been disabled in Xcode 8, so offically you can not see
    // - coloured logs in Xcode 8.
    let xcodeColorsLogFormatter: XcodeColorsLogFormatter = XcodeColorsLogFormatter()
    xcodeColorsLogFormatter.colorize(level: .verbose, with: .lightGrey)
    xcodeColorsLogFormatter.colorize(level: .debug, with: .darkGrey)
    xcodeColorsLogFormatter.colorize(level: .info, with: .blue)
    xcodeColorsLogFormatter.colorize(level: .warning, with: .orange)
    xcodeColorsLogFormatter.colorize(level: .error, with: .red)
    xcodeColorsLogFormatter.colorize(level: .severe, with: .white, on: .red)
    systemDestination.formatters = [xcodeColorsLogFormatter]
    // Add the destination to the logger
    log.add(destination: systemDestination)
    
    log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: logPath)
    
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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions":NSNumber(value: true as Bool)])
        
        Fabric.with([Crashlytics.self])
        
        let mainController = MainWindowController(windowNibName: "MainWindowController")
        mainController.showWindow(self)
        
        self.mainController = mainController
        
        logger.debug("application start")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication)->Bool {
        return true
    }

}

