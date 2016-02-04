//
//  LoginPopoverViewController.swift
//  Train12306
//
//  Created by fancymax on 15/12/6.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Cocoa

protocol LoginPopoverDelegate{
    func didLoginOut()
}

class LoginPopoverViewController: NSViewController {
    
    let service = Service()
    var delegate:LoginPopoverDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func loginOut(sender: AnyObject) {
//        service.loginOut()
        service.removeSession()
        
        MainModel.isGetUserInfo = false
        if let loginOutDelegate = delegate{
            loginOutDelegate.didLoginOut()
        }
    }
}
