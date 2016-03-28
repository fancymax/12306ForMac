//
//  AppDelegate.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

let logger: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.defaultInstance()
    let logPath: NSString = ("~/Desktop/12306ForMac_log.txt" as NSString).stringByExpandingTildeInPath
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
let DidSendSubmitMessageNotification = "com.12306.DidSendSubmitMessageNotification"
let DidSendCheckPassengerMessageNotification = "com.12306.DidSendCheckPassengerMessageNotification"
let DidSendCheckSeatTypeMessageNotification = "com.12306.DidSendCheckSeatTypeMessageNotification"

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {

    var mainController:MainWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
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

