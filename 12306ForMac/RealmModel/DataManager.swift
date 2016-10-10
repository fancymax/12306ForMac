//
//  DataManager.swift
//  12306ForMac
//
//  Created by fancymax on 16/10/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import FMDB

let DATA_DIRECTORY = "\(NSHomeDirectory())/Library/Application Support/\(Bundle.main.bundleIdentifier!)"
let DATA_PATH = "\(DATA_DIRECTORY)/12306ForMac.db"

class DataManger {
    static let sharedInstance = DataManger()
    
    fileprivate init() {
        let isExistDirectory:Bool = FileManager.default.fileExists(atPath: DATA_DIRECTORY, isDirectory: nil)
        if !isExistDirectory {
            do{
                try FileManager.default.createDirectory(atPath: DATA_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                logger.error("Creat \(DATA_DIRECTORY) fail")
            }
        }
    }
    
    func queryAllUsers() -> [UserX] {
        var users=[UserX]()
        let db = FMDatabase(path: DATA_PATH)
        
        if !(db?.open())! {
            logger.error("Could not open db")
            return users
        }
        
        db?.executeStatements("create table if not exists 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,user varchar, password varchar)")
        
        let rs = try! db?.executeQuery("select * from User", values: nil)
        //if rs.counto
        while(rs?.next())!{
            let newUser = UserX()
            newUser.id = (rs?.long(forColumn: "id"))!
            newUser.name = (rs?.string(forColumn: "user"))!
            newUser.password = (rs?.string(forColumn: "password"))!
            
            users.append(newUser)
        }
        db?.close()
        
        return users
    }
    
    func updateUser(_ newUser:UserX) {
        let db = FMDatabase(path: DATA_PATH)
        
        if !(db?.open())! {
            logger.error("Could not open db")
            return
        }
        
        do {
            try db?.executeUpdate("update User set password=? where id=?", values: [newUser.password, newUser.id])
        }
        catch{
            logger.error("updateUser error:\(error)")
        }
        
        defer{
            db?.close()
        }
    }
    
    func inserUser(_ newUser:UserX) {
        let db = FMDatabase(path: DATA_PATH)
        
        if !(db?.open())! {
            logger.error("Could not open db")
            return
        }
        
        do {
            try db?.executeUpdate("insert into User (user,password) values (?, ?)", values: [newUser.name, newUser.password])
        }
        catch {
            logger.error("insertUser error:\(error)")
        }
        
        defer{
            print("db close")
            db?.close()
        }
    }
    
}
