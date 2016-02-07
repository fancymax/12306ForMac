//
//  NFLayerBackedView.m
//  SplitView
//
//  Created by Alexander Cohen on 2014-10-28.
//  Copyright (c) 2014 BedroomCode. All rights reserved.
//

#import "NFLayerBackedView.h"

@implementation NFLayerBackedView

- (void)_commonInit
{
    self.wantsLayer = YES;
    self.backgroundColor = [NSColor whiteColor];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [self _commonInit];
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    [self _commonInit];
    return self;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (NSColor*)backgroundColor
{
    return self.layer.backgroundColor ? [NSColor colorWithCGColor:self.layer.backgroundColor] : nil;
}

- (void)setBorderColor:(NSColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (NSColor*)borderColor
{
    return self.layer.borderColor ? [NSColor colorWithCGColor:self.layer.borderColor] : nil;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

@end
