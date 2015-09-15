//
//  AppDelegate.swift
//  Train12306
//
//  Created by fancymax on 15/7/30.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    var mainController:MainWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        let mainController = MainWindowController(windowNibName: "MainWindowController")
        mainController.showWindow(self)
        
        self.mainController = mainController
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender:NSApplication)->Bool {
        return true
    }


}

