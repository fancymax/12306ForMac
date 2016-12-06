//
//  AdvancePreferenceViewController.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class AdvancedPreferenceViewController: NSViewController,MASPreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if !isUseDama {
            logoutDama()
        }
        else {
            getBalance()
        }
    }
    
    override var nibName: String? {
        return "AdvancedPreferenceViewController"
    }
    
// MARK: - MASPreferencesViewController
    override var identifier: String!{
        get {
            return "AdvancedPreferences"
        }
        set{}
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: NSImageNameAdvanced)
    }
    
    var toolbarItemLabel: String! {
        return NSLocalizedString("打码兔", comment: "")
    }
    
// MARK: - UserDefault
    var isUseDama:Bool {
        get {
            return AdvancedPreferenceManager.sharedInstance.isUseDama
        }
        set {
            AdvancedPreferenceManager.sharedInstance.isUseDama = newValue
            logger.info("dama = \(newValue)")
            if newValue {
                getBalance()
                NotificationCenter.default.post(name: Notification.Name.App.DidDamaGetBalance, object:true)
            }
            else {
                NotificationCenter.default.post(name: Notification.Name.App.DidDamaGetBalance, object:false)
                logoutDama()
            }
        }
    }
    
    var isUseDamaLogin:Bool {
        get{
            return AdvancedPreferenceManager.sharedInstance.isUseDamaLogin
        }
        set{
            AdvancedPreferenceManager.sharedInstance.isUseDamaLogin = newValue
        }
    }
    
    var isStopDamaWhenOperate:Bool {
        get{
            return AdvancedPreferenceManager.sharedInstance.isStopDamaWhenOperate
        }
        set{
            AdvancedPreferenceManager.sharedInstance.isStopDamaWhenOperate = newValue
        }
    }
    
    var isStopDamaWhenFail5:Bool {
        get{
            return AdvancedPreferenceManager.sharedInstance.isStopDamaWhenFail5
        }
        set{
            AdvancedPreferenceManager.sharedInstance.isStopDamaWhenFail5 = newValue
            
        }
    }
    
    var damaUser:String {
        get{
            return AdvancedPreferenceManager.sharedInstance.damaUser
        }
        set{
            AdvancedPreferenceManager.sharedInstance.damaUser = newValue
        }
    }
    
    var damaPassword:String{
        get{
            return AdvancedPreferenceManager.sharedInstance.damaPassword
        }
        set{
            AdvancedPreferenceManager.sharedInstance.damaPassword = newValue
        }
    }
// MARK: - Control and action
    @IBOutlet weak var damaUserlbl: NSTextField!
    @IBOutlet weak var damaPasswordlbl: NSSecureTextField!
    @IBOutlet weak var balancelbl: NSTextField!
    @IBAction func clickGetBalanceOfDama(_ sender: AnyObject) {
        getBalance()
    }
    
    func getBalance() {
        let successHandler = { (balance:String) ->() in
            self.balancelbl.stringValue = "已登录:当前题分 \(balance)"
        }
        
        let failureHandler = { (error:NSError)->() in
            self.balancelbl.stringValue = "登录失败: \(translate(error))"
        }
        
        Dama.sharedInstance.getBalance(damaUser, password: damaPassword, success: successHandler, failure: failureHandler)
    }
    
    func logoutDama() {
        self.balancelbl.stringValue = "未登录"
    }
    
}
