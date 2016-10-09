//
//  DataManager.swift
//  12306ForMac
//
//  Created by fancymax on 16/10/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import FMDB

let DATA_DIRECTORY = "\(NSHomeDirectory())/Library/Application Support/\(NSBundle.mainBundle().bundleIdentifier!)"
let DATA_PATH = "\(DATA_DIRECTORY)/12306ForMac.db"

class DataManger {
    static let sharedInstance = DataManger()
    
    private init() {
        let isExistDirectory:Bool = NSFileManager.defaultManager().fileExistsAtPath(DATA_DIRECTORY, isDirectory: nil)
        if !isExistDirectory {
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(DATA_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                logger.error("Creat \(DATA_DIRECTORY) fail")
            }
        }
    }
    
    func queryAllUsers() -> [UserX] {
        var users=[UserX]()
        let db = FMDatabase(path: DATA_PATH)
        
        if !db.open() {
            logger.error("Could not open db")
            return users
        }
        
        db.executeStatements("create table if not exists 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,user varchar, password varchar)")
        
        let rs = try! db.executeQuery("select * from User", values: nil)
        //if rs.counto
        while(rs.next()){
            let newUser = UserX()
            newUser.id = rs.longForColumn("id")
            newUser.name = rs.stringForColumn("user")
            newUser.password = rs.stringForColumn("password")
            
            users.append(newUser)
        }
        db.close()
        
        return users
    }
    
    func updateUser(newUser:UserX) {
        let db = FMDatabase(path: DATA_PATH)
        
        if !db.open() {
            logger.error("Could not open db")
            return
        }
        
        do {
            try db.executeUpdate("update User set password=? where id=?", values: [newUser.password, newUser.id])
        }
        catch{
            logger.error("updateUser error:\(error)")
        }
        
        defer{
            db.close()
        }
    }
    
    func inserUser(newUser:UserX) {
        let db = FMDatabase(path: DATA_PATH)
        
        if !db.open() {
            logger.error("Could not open db")
            return
        }
        
        do {
            try db.executeUpdate("insert into User (user,password) values (?, ?)", values: [newUser.name, newUser.password])
        }
        catch {
            logger.error("insertUser error:\(error)")
        }
        
        defer{
            print("db close")
            db.close()
        }
    }
    
}