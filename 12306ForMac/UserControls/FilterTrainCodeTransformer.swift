//
//  FilterTrainCodeTransformer.swift
//  12306ForMac
//
//  Created by fancymax on 16/9/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

@objc(FilterTrainCodeTransformer) class FilterTrainCodeTransformer: NSValueTransformer {
    
    override class func allowsReverseTransformation()->Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if value == nil {
            return nil
        }
        let presentation = value as! String
        let range = presentation.rangeOfString("|1")!
        return presentation.substringToIndex(range.startIndex)
    }

}

@objc(FilterTrainTimeTransformer) class FilterTrainTimeTransformer: NSValueTransformer {
    
    override class func allowsReverseTransformation()->Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if value == nil {
            return nil
        }
        let presentation = value as! String
        let range1 = presentation.rangeOfString("|1")!
        let range2 = presentation.rangeOfString("|2")!
        return presentation.substringWithRange(range1.endIndex..<range2.startIndex)
    }
}

@objc(FilterTrainStationTransformer) class FilterTrainStationTransformer: NSValueTransformer {
    
    override class func allowsReverseTransformation()->Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if value == nil {
            return nil
        }
        let presentation = value as! String
        let range = presentation.rangeOfString("|2")!
        return presentation.substringFromIndex(range.endIndex)
    }
    
}
