//
//  DJProgressIndicator.m
//  Playground
//
//  Created by Daniel Jackson on 5/11/14.
//  Copyright (c) 2014 Daniel Jackson. All rights reserved.
//

#import "DJActivityIndicator.h"

#define kAlphaWhenStopped   0.15
#define kFadeMultiplier     0.85

@interface DJActivityIndicator ()
{
    int position;
    NSMutableArray* finColors;
    
    BOOL isFadingOut;
    NSTimer* animationTimer;
    
    NSColor* foreColor;
    NSColor* backColor;
}
@end

@implementation DJActivityIndicator

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        position = 0;
        int numFins = 12;
        
        finColors = [[NSMutableArray alloc] initWithCapacity:numFins];
        
        _isAnimating = NO;
        isFadingOut = NO;
        
        foreColor = [NSColor blackColor];
        backColor = [NSColor clearColor];
        
        for(int i=0; i<numFins; i++)
        {
            [finColors addObject:foreColor];
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSSize size = [self bounds].size;
    CGFloat theMaxSize;
    if(size.width >= size.height)
        theMaxSize = size.height;
    else
        theMaxSize = size.width;
    
    [backColor set];
    [NSBezierPath fillRect:[self bounds]];
    
    CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    [NSGraphicsContext saveGraphicsState];
    
    CGContextTranslateCTM(currentContext,[self bounds].size.width/2,[self bounds].size.height/2);
    
    NSBezierPath *path = [[NSBezierPath alloc] init];
    CGFloat lineWidth = 0.0859375 * theMaxSize;
    CGFloat lineStart = 0.234375 * theMaxSize;
    CGFloat lineEnd = 0.421875 * theMaxSize;
    [path setLineWidth:lineWidth];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path moveToPoint:NSMakePoint(0,lineStart)];
    [path lineToPoint:NSMakePoint(0,lineEnd)];
    
    for (int i=0; i<finColors.count; i++) {
        if(_isAnimating) {
            [(NSColor*)finColors[i] set];
        }
        else {
            [[foreColor colorWithAlphaComponent:kAlphaWhenStopped] set];
        }
        
        [path stroke];
        
        CGContextRotateCTM(currentContext, 6.282185/finColors.count);
    }
    path = nil;
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)startAnimation:(id)sender
{
    if (_isAnimating && !isFadingOut) return;
	
    [self actuallyStartAnimation];
}

- (void)stopAnimation:(id)sender
{
    isFadingOut = YES;
}

- (void)setColor:(NSColor *)value
{
    if (foreColor != value) {
        foreColor = nil;
        foreColor = value;
        
        for (int i=0; i<finColors.count; i++) {
            CGFloat alpha = [finColors[i] alphaComponent];
            [finColors setObject:[foreColor colorWithAlphaComponent:alpha] atIndexedSubscript:i];
        }
        
        [self setNeedsDisplay:YES];
    }
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (backColor != value) {
        backColor = nil;
        backColor = value;
        [self setNeedsDisplay:YES];
    }
}

- (void)updateFrame:(NSTimer *)timer
{
    if(position > 0) {
        position--;
    }
    else {
        position = (int)finColors.count - 1;
    }
    
    CGFloat minAlpha = kAlphaWhenStopped;
    for (int i=0; i<finColors.count; i++) {
        CGFloat newAlpha = [finColors[i] alphaComponent] * kFadeMultiplier;
        if (newAlpha < minAlpha)
            newAlpha = minAlpha;

        finColors[i] = [foreColor colorWithAlphaComponent:newAlpha];
    }
    
    if (isFadingOut) {
        BOOL done = YES;
        for (int i=0; i<finColors.count; i++) {
            if (fabs([finColors[i] alphaComponent] - minAlpha) > 0.01) {
                done = NO;
                break;
            }
        }
        if (done) {
            [self actuallyStopAnimation];
        }
    }
    else {
        finColors[position] = foreColor;
    }
                
    [self setNeedsDisplay:YES];
        

}

- (void)actuallyStartAnimation
{
    [self actuallyStopAnimation];
    
    _isAnimating = YES;
    isFadingOut = NO;
    
    position = 1;
    
    animationTimer = [NSTimer timerWithTimeInterval:(NSTimeInterval)0.05
                                               target:self
                                             selector:@selector(updateFrame:)
                                             userInfo:nil
                                              repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSEventTrackingRunLoopMode];
}

- (void)actuallyStopAnimation
{
    _isAnimating = NO;
    isFadingOut = NO;
    
    if (animationTimer) {
        // we were using timer-based animation
        [animationTimer invalidate];
        animationTimer = nil;
    }
    //[self setNeedsDisplay:YES];
}




@end
