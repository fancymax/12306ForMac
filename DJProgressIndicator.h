//
//  DJProgressIndicator.h
//  Playground
//
//  Created by Daniel Jackson on 5/11/14.
//  Copyright (c) 2014 Daniel Jackson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface DJProgressIndicator : NSView

@property (nonatomic,readonly) CGFloat currentProgress;

- (void)setBackgroundColor:(NSColor *)value;
- (void)setRingColor:(NSColor *)value backgroundRingColor:(NSColor*)value2;
- (void)setRingThickness:(CGFloat)thick;
- (void)setRingRadius:(CGFloat)radius;

- (void)showProgress:(float)progress;

-(void)sizeToFit;

-(void)clear;

@property (nonatomic, readonly) CGFloat ringRadius;
@property (nonatomic, readonly) CGFloat ringThickness;

@end
