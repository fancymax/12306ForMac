//
//  DJLayerView.h
//  Playground
//
//  Created by fancymax on 16/10/24.
//  Copyright © 2016年 Daniel Jackson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DJLayerView : NSView

+(void)showStatus:(NSString*)status FromView:(NSView *)view;
+(void)dismiss;

// Customization
#define pMaxWidth1 250
#define pMaxHeight1 200

//General Popup Values
@property (nonatomic) CGVector pOffset;
@property (nonatomic) CGFloat pAlpha;

//Padding
@property (nonatomic) CGFloat pPadding;

@property (nonatomic) CGSize indicatorSize;
@property (nonatomic) CGVector indicatorOffset;
@property (nonatomic) CGSize labelSize;
@property (nonatomic) CGVector labelOffset;

@end
