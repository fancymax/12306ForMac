//
//  DJProgressIndicator.m
//  Playground
//
//  Created by Daniel Jackson on 5/11/14.
//  Copyright (c) 2014 Daniel Jackson. All rights reserved.
//

#import "DJProgressIndicator.h"
#import "DJBezierPath.h"

@interface DJProgressIndicator ()
{
    NSColor* backRingColor;
    NSColor* ringColor;
    NSColor* backColor;
}

@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@end

@implementation DJProgressIndicator

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentProgress = 0;
        
        _ringThickness = 6;
        _ringRadius = self.frame.size.width/2 - (_ringThickness);
        
        backRingColor = [NSColor darkGrayColor];
        ringColor = [NSColor whiteColor];
        backColor = [NSColor clearColor];
        
        [self setAutoresizesSubviews:YES];

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    //NSLog(@"Drawing");
    
    [self setBackground];
    
    [self resetRings];
}

- (void)setBackground
{
    if(![self wantsLayer])
    {
        CALayer* bgLayer = [CALayer layer];
        [bgLayer setBackgroundColor:backColor.CGColor];
        [self setWantsLayer:TRUE];
        [self setLayer:bgLayer];
    }
    else {
        [self.layer setBackgroundColor:backColor.CGColor];
    }
}

- (void)resetRings
{
    [_ringLayer removeFromSuperlayer];
    _ringLayer = nil;
    [_backgroundRingLayer removeFromSuperlayer];
    _backgroundRingLayer = nil;
    
    [self updateLayout];
    self.ringLayer.strokeEnd = _currentProgress;
}

-(void)updateLayout
{
    self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.bounds)/2), CGRectGetHeight(self.bounds)/2);
}

- (void)showProgress:(float)progress {

    NSLog(@"-----%f",progress);

    _currentProgress = progress;
    
    [self updateLayout];
    
    if(progress >= 0) {
        self.ringLayer.strokeEnd = progress;
    }
    else {
        [self cancelRingLayerAnimation];
    }
    
    //[self setNeedsDisplay:TRUE];
}

- (CAShapeLayer *)ringLayer {
    if(!_ringLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        _ringLayer = [self createRingLayerWithCenter:center radius:_ringRadius lineWidth:_ringThickness color:ringColor];
        [self.layer addSublayer:_ringLayer];
    }
    return _ringLayer;
}

- (CAShapeLayer *)backgroundRingLayer {
    if(!_backgroundRingLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        _backgroundRingLayer = [self createRingLayerWithCenter:center radius:_ringRadius lineWidth:_ringThickness color:backRingColor];
        _backgroundRingLayer.strokeEnd = 1;
        [self.layer addSublayer:_backgroundRingLayer];
    }
    return _backgroundRingLayer;
}

- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.layer removeAllAnimations];
    
    _ringLayer.strokeEnd = 0.0f;
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if (_backgroundRingLayer.superlayer) {
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

-(void)clear
{
    [self cancelRingLayerAnimation];
}

- (CGPoint)pointOnCircleWithCenter:(CGPoint)center radius:(double)radius angleInDegrees:(double)angleInDegrees {
    float x = (float)(radius * cos(angleInDegrees * M_PI / 180)) + radius;
    float y = (float)(radius * sin(angleInDegrees * M_PI / 180)) + radius;
    return CGPointMake(x, y);
}


- (DJBezierPath *)createCirclePathWithCenter:(CGPoint)center radius:(CGFloat)radius sampleCount:(NSInteger)sampleCount {
    
    DJBezierPath *smoothedPath = [[DJBezierPath alloc] init];
    CGPoint startPoint = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:90];
    
    [smoothedPath moveToPoint:startPoint];
    
    CGFloat delta = 360.0f/sampleCount;
    CGFloat angleInDegrees = 90;
    for (NSInteger i=1; i<sampleCount; i++) {
        angleInDegrees -= delta;
        CGPoint point = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:angleInDegrees];
        [smoothedPath lineToPoint:point];
    }
    
    [smoothedPath lineToPoint:startPoint];
    
    return smoothedPath;
}


- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(NSColor *)color {
    
    DJBezierPath *smoothedPath = [self createCirclePathWithCenter:center radius:radius sampleCount:72];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [NSColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    
    CGPathRef path = smoothedPath.quartzPath;
    slice.path = path;
    CGPathRelease(path);
    
    
    return slice;
}


- (void)setRingColor:(NSColor *)value backgroundRingColor:(NSColor*)value2
{
    bool changed = false;
    
    if (ringColor != value) {
        ringColor = nil;
        ringColor= value;
        changed = true;
    }
    if (backRingColor != value2) {
        backRingColor = nil;
        backRingColor = value2;
        changed = true;
    }
    if(changed) {
        [self resetRings];
        [self setNeedsDisplay:TRUE];
    }
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (backColor != value) {
        //[backColor release];
        backColor = nil;
        backColor = value;
        [self setBackground];
        //[self setNeedsDisplay:TRUE];
    }
}

- (void)setRingThickness:(CGFloat)thick
{
    if(_ringThickness != thick) {
        _ringThickness = thick;
        [self resetRings];
        //[self setNeedsDisplay:TRUE];
    }
}

- (void)setRingRadius:(CGFloat)radius
{
    if(_ringRadius != radius) {
        _ringRadius = radius;
        [self resetRings];
        //[self setNeedsDisplay:TRUE];
    }
}

- (void)sizeToFit {
    _ringRadius = self.frame.size.width/2 - (_ringThickness);
}

@end
