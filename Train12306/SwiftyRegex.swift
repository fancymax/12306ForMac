//
//  SwiftRegex.swift
//  Train12306
//
//  Created by fancymax on 15/7/31.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression?
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)
    }
    
    func getMatches(input: String) -> [[String]]? {
        var res = [[String]]()
        let myRange = NSMakeRange(0, count(input))
        if let matches = self.internalExpression?.matchesInString(input, options: nil, range:myRange) as? [NSTextCheckingResult]
        {
            for match in matches
            {
                var groupMatch = [String]()
                for i in 1..<match.numberOfRanges
                {
                    let rangeText = (input as NSString).substringWithRange(match.rangeAtIndex(i))
                    groupMatch.append(rangeText)
                }
                res.append(groupMatch)
            }
        }
        return res
    }
}