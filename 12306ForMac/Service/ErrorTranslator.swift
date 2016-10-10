//
//  ErrorTranslator.swift
//  12306ForMac
//
//  Created by fancymax on 16/3/9.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

func translate(_ error:NSError)->String{
    
    if error.domain == "NSURLErrorDomain"{
        if error.code == -1009 {
            return "网络连接失败，请检查连接或稍后再试"
        }
    }
    if let err = error.localizedFailureReason{
        return err
    }
    else{
        return error.localizedDescription
    }
}
