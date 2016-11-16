//
//  FilterTrainCodeTransformer.swift
//  12306ForMac
//
//  Created by fancymax on 16/9/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

@objc(FilterTrainCodeTransformer)
class FilterTrainCodeTransformer: ValueTransformer {
    
    override class func allowsReverseTransformation()->Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value == nil {
            return nil
        }
        let presentation = value as! String
        let range = presentation.range(of: "|1")!
        return presentation.substring(to: range.lowerBound)
    }

}

@objc(FilterTrainTimeTransformer)
class FilterTrainTimeTransformer: ValueTransformer {
    
    override class func allowsReverseTransformation()->Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value == nil {
            return nil
        }
        let presentation = value as! String
        let range1 = presentation.range(of: "|1")!
        let range2 = presentation.range(of: "|2")!
        return presentation.substring(with: range1.upperBound..<range2.lowerBound)
    }
}

@objc(FilterTrainStationTransformer)
class FilterTrainStationTransformer: ValueTransformer {
    
    override class func allowsReverseTransformation()->Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value == nil {
            return nil
        }
        let presentation = value as! String
        let range = presentation.range(of: "|2")!
        return presentation.substring(from: range.upperBound)
    }
    
}
