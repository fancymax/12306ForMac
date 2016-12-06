//
//  Notifications.swift
//  12306ForMac
//
//  Created by fancymax on 2016/11/14.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

extension Notification.Name {
    public struct App {
        public static let DidLogin = Notification.Name(rawValue: "com.12306ForMac.App.DidLogin")
        
        public static let DidLogout = Notification.Name(rawValue: "com.12306ForMac.App.DidLogout")
        
        public static let DidSubmit = Notification.Name(rawValue: "com.12306ForMac.App.DidSubmit")
        
        public static let DidCheckPassenger = Notification.Name(rawValue: "com.12306ForMac.App.DidCheckPassenger")
        
        public static let DidAutoLogin = Notification.Name(rawValue: "com.12306ForMac.App.DidAutoLogin")
        
        public static let DidAutoSubmit = Notification.Name(rawValue: "com.12306ForMac.App.DidAutoSubmit")
        
        public static let DidAddDefaultPassenger = Notification.Name(rawValue: "com.12306ForMac.App.DidAddDefaultPassenger")
        
        public static let DidDamaGetBalance = Notification.Name(rawValue: "com.12306ForMac.App.DidDamaGetBalance")
    }
}
