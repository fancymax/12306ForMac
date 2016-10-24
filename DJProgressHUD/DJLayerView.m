//
//  DJLayerView.m
//  Playground
//
//  Created by fancymax on 16/10/24.
//  Copyright © 2016年 Daniel Jackson. All rights reserved.
//

#import "DJLayerView.h"
#import "DJActivityIndicator.h"

@interface DJLayerView(){
    NSView* parentView;
    
    CGSize pSize; //This is set automatically based on the content
    DJActivityIndicator* activityIndicator;
    NSTextField* label;
}

@end

@implementation DJLayerView

+(void)showStatus:(NSString *)status FromView:(NSView *)parentView{
    [[self instance] showStatus:status FromView:parentView];
}

+(void)dismiss {
    [[self instance] finishHideView];
}

-(void)finishHideView
{
    [self removeFromSuperview];
    parentView = nil;
    
    [activityIndicator stopAnimation:nil];
}

-(void)showStatus:(NSString*)status FromView:(NSView *)view {
    parentView = view;
    label.stringValue = status;
    [activityIndicator startAnimation:nil];
    
    if (!self.superview) {
        [parentView addSubview:self];
    }

    [self updateLayout];
    
    CGColorRef bgcolor = CGColorCreateGenericRGB(0.05, 0.05, 0.05, 0.8);
    self.layer.backgroundColor = bgcolor;
    self.layer.cornerRadius = 15.0;
    [self setFrame:[self getCenterWithinRect:parentView.frame scale:1]];
}

- (NSRect)getCenterWithinRect:(NSRect)parentFrame scale:(CGFloat)scale
{
    NSRect result;
    CGFloat newWidth = pSize.width*scale;
    CGFloat newHeight = pSize.height*scale;
    result.origin.x = parentFrame.size.width/2 - newWidth/2 + _pOffset.dx;
    result.origin.y = parentFrame.size.height/2 - newHeight/2 + _pOffset.dy;
    result.size.width = newWidth;
    result.size.height = newHeight;
    
    return result;
}

- (void)updateLayout
{
    CGSize maxContentSize = CGSizeMake(pMaxWidth1-(_pPadding*2), pMaxHeight1-(_pPadding*2));
    CGSize minContentSize = CGSizeMake(_indicatorSize.width, _indicatorSize.height);
    
    CGFloat stringWidth = [label.stringValue sizeWithAttributes:@{ NSFontAttributeName : label.font }].width + 5;
    float stringHeight = [self heightForString:label.stringValue font:label.font width:maxContentSize.width] + 8;
    
    if(label.stringValue == nil || label.stringValue.length == 0)
        stringHeight = 0;
    
    stringWidth = (stringWidth > minContentSize.width) ? stringWidth : minContentSize.width;
    if(stringWidth > maxContentSize.width)
        stringWidth = maxContentSize.width;
    
    CGFloat maxStringHeight = maxContentSize.height-_indicatorSize.height-(_pPadding+(_pPadding/2));
    stringHeight = (stringHeight > maxStringHeight) ? maxStringHeight : stringHeight;
    
    CGFloat popupWidth = stringWidth+(_pPadding*2);
    
    CGFloat lW = stringWidth;
    CGFloat lH = stringHeight;
    CGFloat lX = _pPadding;
    CGFloat lY = (stringHeight == 0) ? 0 : _pPadding;
    [label setFrame:NSMakeRect(lX, lY, lW, lH)];
    
    CGFloat spaceBetween = (stringHeight != 0) ? _pPadding/3 : _pPadding;
    
    CGFloat iW = _indicatorSize.width;
    CGFloat iH = _indicatorSize.height;
    CGFloat iX = ((lW+(_pPadding*2))/2)-(iW/2); //center it
    CGFloat iY = lY+lH+(spaceBetween);
    NSRect indicatorRect = NSMakeRect(iX, iY, iW, iH);
    activityIndicator.frame = indicatorRect;
    
    CGFloat spaceOnTop = (stringHeight != 0) ? _pPadding/3 : 0;
    
    [activityIndicator setColor:[NSColor whiteColor]];
    
    pSize.width = popupWidth;
    pSize.height = iY+iH+_pPadding+spaceOnTop;//+(_pPadding/2);
    
    [self setAutoresizesSubviews:YES];
}

-(CGFloat) heightForString:(NSString *)myString font:(NSFont*) myFont width:(CGFloat)myWidth
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:myString];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)];
    ;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager
            usedRectForTextContainer:textContainer].size.height;
}

- (void)initializePopup
{
    [self setWantsLayer:YES];
    
    self.autoresizingMask = NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin;
    
    activityIndicator = [[DJActivityIndicator alloc] init];
    label = [[NSTextField alloc] init];
    
    [self addSubview:label];
    [self addSubview:activityIndicator];
    
    //----DEFAULT VALUES----
    
    _pOffset = CGVectorMake(0, 0);
    _pAlpha = 0.9;
    _pPadding = 10;
    
    _indicatorSize = CGSizeMake(30, 30);
    _indicatorOffset = CGVectorMake(0, 0);
    
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    
    label.font = [NSFont systemFontOfSize:13.0];
    [label setTextColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.85]];
}

+ (DJLayerView *) instance
{
    static dispatch_once_t once;
    static DJLayerView *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[self alloc] init];
        [sharedView initializePopup];
    });
    
    return sharedView;
}

@end
