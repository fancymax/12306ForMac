//
//  Dama.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Int {
    func hexedString() -> String {
        return NSString(format:"%02x", self) as String
    }
}

extension Data {
    func hexedString() -> String {
        let buffer = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        
        var hexadecimalString = ""
        for i in 0..<self.count {
            hexadecimalString += String(format: "%02x", buffer.advanced(by: i).pointee)
        }
        return hexadecimalString
    }
    
    func MD5() throws -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_MD5($0, CC_LONG(self.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    func SHA1() throws -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(self.count), &hash)
        }
        return Data(bytes: hash)
    }
    
}

extension String {
    
    func MD5() -> String {
        do {
            return try self.data(using: String.Encoding.utf8)!.MD5().hexedString()
        } catch {
        }
        return ""
    }
    
    func SHA1() -> String {
        do {
            return try self.data(using: String.Encoding.utf8)!.SHA1().hexedString()
        } catch {
        }
        return ""
    }
}

class Dama: NSObject {
    
    static let sharedInstance = Dama()
    
    let AppId:String = "43327"
    let AppKey:String = "36f3ff0b2f66f2b3f1cd9b5953095858"
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate func getCurrentFileHex(ofImage image:NSImage)->String {
        let originData = image.tiffRepresentation
        let imageRep = NSBitmapImageRep(data: originData!)
        let imageData = imageRep!.representation(using: .PNG, properties: ["NSImageCompressionFactor":1.0])!
        
        let result = imageData.hexedString()
        return result
    }
    
    fileprivate func getpwd(_ user:String,password:String) -> String{
        let nameMD5 = user.MD5()
        let passwordMD5 = password.MD5()
        let x1MD5 = (nameMD5 + passwordMD5).MD5()
        
        let x2MD5 = (AppKey + x1MD5).MD5()
        return x2MD5
    }
    
    fileprivate func getsign(ofUser user:String) ->String {
        let key = AppKey + user
        let x1MD5 = key.MD5()
        let startIndex = x1MD5.startIndex
        let x2 = x1MD5[startIndex...x1MD5.index(startIndex, offsetBy: 7)]
        return x2
    }
    
    fileprivate func getFileDataSign2(ofImage image:NSImage,user:String)->String{
        let originData = image.tiffRepresentation
        let imageRep = NSBitmapImageRep(data: originData!)
        let imageData = imageRep!.representation(using: .PNG, properties: ["NSImageCompressionFactor":1.0])!
        
        let AppKeyData = AppKey.data(using: String.Encoding.utf8)
        let AppUserData = user.data(using: String.Encoding.utf8)
        
        
        var finalData = Data()
        finalData.append(AppKeyData!)
        finalData.append(AppUserData!)
        finalData.append(imageData)
        do {
            let x1MD5 = try finalData.MD5().hexedString()
            let startIndex = x1MD5.startIndex
            let x2 = x1MD5[startIndex...x1MD5.index(startIndex, offsetBy: 7)]
            return x2
        } catch {
            
        }
        return ""
    }
    
    func getBalance(_ user:String,password:String,success:@escaping (_ balance:String)->(),failure:@escaping (_ error:NSError)->()){
        
        let url = "http://api.dama2.com:7766/app/d2Balance"
        let pwd = getpwd(user,password: password)
        let sign = getsign(ofUser: user)
        
        let urlX = "\(url)?appID=\(AppId)&user=\(user)&pwd=\(pwd)&sign=\(sign)"
        Alamofire.request(urlX).responseJSON { response in
                switch(response.result){
                case .failure(let error):
                    failure(error as NSError)
                case .success(let data):
                    if let balanceVal = JSON(data)["balance"].string {
                        success(balanceVal)
                    } else {
                        if let errorCode = JSON(data)["ret"].int {
                            failure(DamaError.errorWithCode(errorCode))
                        }
                    }
                }
        }
    }
    
    func dama(_ user:String,password:String,ofImage image:NSImage,success:@escaping (_ imageCode:String)->(),failure:@escaping (_ error:NSError)->()){
        
        let pwd = getpwd(user,password: password)
        let sign = getFileDataSign2(ofImage: image,user: user)
        let type = "287"
        let fileData = getCurrentFileHex(ofImage: image)
        let url = "http://api.dama2.com:7766/app/d2File"
        
        let params = ["appID":AppId,
                      "user":user,
                      "pwd":pwd,
                      "type":type,
                      "fileData":fileData,
                      "sign":sign]
        Alamofire.request(url,parameters: params).responseJSON { response in
            switch(response.result) {
            case .failure(let error):
                failure(error as NSError)
            case .success(let data):
                if let imageCode = JSON(data)["result"].string {
                    success(imageCode)
                } else {
                    if let errorCode = JSON(data)["ret"].int {
                        failure(DamaError.errorWithCode(errorCode))
                    }
                }
            }
        }
    }
    
}
