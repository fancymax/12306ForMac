//
//  NFLayerBackedView.h
//  SplitView
//
//  Created by Alexander Cohen on 2014-10-28.
//  Copyright (c) 2014 BedroomCode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NFLayerBackedView : NSView

@property (nonatomic,strong) NSColor* backgroundColor;

@property (nonatomic,strong) NSColor* borderColor;
@property (nonatomic,assign) CGFloat borderWidth;

@end
