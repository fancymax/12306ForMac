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
    let log = XCGLogger.default
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddhhmm"
    let dateStr = dateFormatter.string(from: Date())
    
    let bundleId = Bundle.main.bundleIdentifier!
    let fileName = "\(bundleId).\(dateStr).txt"

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
    
    log.setup(level: .debug, showThreadName: false, showLevel: true, showFileNames: false, showLineNumbers: false, writeToFile: APP_LOG_PATH as AnyObject?)
    
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

