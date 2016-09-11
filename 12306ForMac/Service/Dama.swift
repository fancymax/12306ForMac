//
//  Dama.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/10.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation
import Alamofire

extension Int {
    func hexedString() -> String {
        return NSString(format:"%02x", self) as String
    }
}

extension NSData {
    func hexedString() -> String {
        var string = String()
        for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
            string += Int(i).hexedString()
        }
        return string
    }
    
    func MD5() -> NSData {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
    
    func SHA1() -> NSData {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
}

extension String {
    func MD5() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.MD5().hexedString()
    }
    
    func SHA1() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.SHA1().hexedString()
    }
}

class Dama: NSObject {
    
    static let sharedInstance = Dama()
    
    let AppId:String = "43327"
    let AppKey:String = "36f3ff0b2f66f2b3f1cd9b5953095858"
    
    private override init() {
        super.init()
    }
    
    private func getCurrentFileHex(ofImage image:NSImage)->String {
        let originData = image.TIFFRepresentation
        let imageRep = NSBitmapImageRep(data: originData!)
        let imageData = imageRep!.representationUsingType(.NSPNGFileType, properties: ["NSImageCompressionFactor":1.0])!
        
        let result = imageData.hexedString()
        return result
    }
    
    private func getpwd(user:String,password:String) -> String{
        let nameMD5 = user.MD5()
        let passwordMD5 = password.MD5()
        let x1MD5 = (nameMD5 + passwordMD5).MD5()
        
        let x2MD5 = (AppKey + x1MD5).MD5()
        return x2MD5
    }
    
    private func getsign(ofUser user:String) ->String {
        let key = AppKey + user
        let x1MD5 = key.MD5()
        let x2 = x1MD5[x1MD5.startIndex...x1MD5.startIndex.advancedBy(7)]
        return x2
    }
    
    private func getFileDataSign2(ofImage image:NSImage,user:String)->String{
        let originData = image.TIFFRepresentation
        let imageRep = NSBitmapImageRep(data: originData!)
        let imageData = imageRep!.representationUsingType(.NSPNGFileType, properties: ["NSImageCompressionFactor":1.0])!
        
        let AppKeyData = AppKey.dataUsingEncoding(NSUTF8StringEncoding)
        let AppUserData = user.dataUsingEncoding(NSUTF8StringEncoding)
        
        let finalData:NSMutableData = NSMutableData(data: AppKeyData!)
        finalData.appendData(AppUserData!)
        finalData.appendData(imageData)
        
        let x1MD5 = finalData.MD5().hexedString()
        let x2 = x1MD5[x1MD5.startIndex...x1MD5.startIndex.advancedBy(7)]
        return x2
    }
    
    func getBalance(user:String,password:String,success:(balance:String)->(),failure:(error:NSError)->()){
        
        let url = "http://api.dama2.com:7766/app/d2Balance"
        let pwd = getpwd(user,password: password)
        let sign = getsign(ofUser: user)
        
        let urlX = "\(url)?appID=\(AppId)&user=\(user)&pwd=\(pwd)&sign=\(sign)"
        Alamofire.request(.GET, urlX).responseJSON { response in
                switch(response.result){
                case .Failure(let error):
                    failure(error: error)
                case .Success(let data):
                    if let balanceVal = JSON(data)["balance"].string {
                        success(balance: balanceVal)
                    }
                    else {
                        if let errorCode = JSON(data)["ret"].int {
                            failure(error: DamaError.errorWithCode(errorCode))
                        }
                    }
                }
                //耗时：print(response.timeline.totalDuration)
        }
    }
    
    func dama(user:String,password:String,ofImage image:NSImage,success:(imageCode:String)->(),failure:(error:NSError)->()){
        
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
        Alamofire.request(.POST, url,parameters: params).responseJSON { response in
            switch(response.result) {
            case .Failure(let error):
                failure(error: error)
            case .Success(let data):
                if let imageCode = JSON(data)["result"].string {
                    success(imageCode: imageCode)
                }
                else {
                    if let errorCode = JSON(data)["ret"].int {
                        failure(error: DamaError.errorWithCode(errorCode))
                    }
                }
            }
        }
    }
    
}