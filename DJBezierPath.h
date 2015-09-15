//
//  CPBezierPath.h
//  Cloud Play OSX
//
//  Created by Daniel Jackson on 5/11/14.
//  Copyright (c) 2014 Daniel Jackson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DJBezierPath : NSBezierPath

- (CGPathRef)quartzPath;

@end
