//
//  MainModel.swift
//  Train12306
//
//  Created by fancymax on 15/10/6.
//  Copyright © 2015年 fancy. All rights reserved.
//

import Foundation

class MainModel{
    static var realName = ""
    static var userName = ""
    static var isGetUserInfo = false
    
    static var passengers = [PassengerDTO]()
    static var selectPassengers = [PassengerDTO]()
    static var isGetPassengersInfo = false
    
    static var selectedTicket:QueryLeftNewDTO?
    
    static var orderId:String?
    
    static var globalRepeatSubmitToken:String?
    static var key_check_isChange:String?
    static var train_location:String?
    static var trainDate:String?
    
    static var historyOrderList:[OrderDTO] = []
    static var noCompleteOrderList:[OrderDTO] = []
    
}

