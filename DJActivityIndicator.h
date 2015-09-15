//
//  DJProgressIndicator.h
//  Playground
//
//  Created by Daniel Jackson on 5/11/14.
//  Copyright (c) 2014 Daniel Jackson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DJActivityIndicator : NSView

@property BOOL isAnimating;

- (void)setColor:(NSColor *)value;
- (void)setBackgroundColor:(NSColor *)value;

- (void)stopAnimation:(id)sender;
- (void)startAnimation:(id)sender;
 
@end
