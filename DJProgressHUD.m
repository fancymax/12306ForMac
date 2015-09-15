//
//  CPProgressView.m
//  Cloud Play OSX
//
//  Created by Daniel Jackson on 4/22/14.
//  Copyright (c) 2014 Daniel Jackson. All rights reserved.
//

#import "DJProgressHUD.h"
#import "DJActivityIndicator.h"
#import "DJProgressIndicator.h"

#define DEBUG_LOGS 1

typedef void (^CompletionHander)(void);

@interface DJProgressHUD ()
{
    NSView* parentView;
    
    CGSize pSize; //This is set automatically based on the content
    DJActivityIndicator* activityIndicator;
    DJProgressIndicator* progressIndicator;
    NSTextField* label;
    
    NSButton* backgroundMask;
    NSView* MainHUD;
}

@property CGFloat backgroundAlpha;
@property BOOL actionsEnabled;

@end

@implementation DJProgressHUD

#pragma mark -
#pragma mark Class Methods

+ (void)showStatus:(NSString*)status FromView:(NSView*)view
{
    [[self instance] showStatus:status FromView:view];
}

+ (void)setBackgroundAlpha:(CGFloat)bgAlph disableActions:(BOOL)disActions
{
    DJProgressHUD* theHUD = [self instance];
    theHUD.backgroundAlpha = bgAlph;

    [theHUD setBackground];
    
}

+ (void)showProgress:(CGFloat)progress withStatus:(NSString*)status FromView:(NSView*)view
{
    [[self instance] showProgress:progress withStatus:status FromView:view];
}

+ (void)dismiss
{
    if([[self instance] keepActivityCount]) {
        [[self instance] popActivity];
    }
    else {
        [[self instance] hideViewAnimated];
    }
}

+ (void)popActivity
{
    [[self instance] popActivity];
}

#pragma mark -
#pragma mark Master Methods

- (void)showStatus:(NSString*)status FromView:(NSView*)view
{
    parentView = view;
    
    label.stringValue = status;
    
    [activityIndicator setHidden:FALSE];
    [progressIndicator setHidden:TRUE];
    [activityIndicator startAnimation:nil];

    if(![self displaying])
        [self showViewAnimated];
    else
        [self replaceViewQuick];
}

- (void)addMask {
    
    [backgroundMask removeFromSuperview];
    [backgroundMask setFrame:parentView.frame];
    [backgroundMask setEnabled:!_actionsEnabled];
    if(!backgroundMask.wantsLayer) {
        CALayer* layer = [CALayer layer];
        [backgroundMask setLayer:layer];
    }
    [backgroundMask.layer setOpacity:0.0];
    [parentView addSubview:backgroundMask positioned:NSWindowAbove relativeTo:self];
}

- (void)removeMask {
    
    [backgroundMask removeFromSuperview];
//    [backgroundMask.animator.layer setOpacity:0.0];
}

- (void)showProgress:(CGFloat)progress withStatus:(NSString*)status FromView:(NSView*)view
{
    parentView = view;
    
    label.stringValue = status;
    
    [activityIndicator setHidden:TRUE];
    [progressIndicator setHidden:FALSE];
    [activityIndicator stopAnimation:nil];
    [progressIndicator showProgress:progress];
    
    if(![self displaying])
        [self showViewAnimated];
    else
        [self replaceViewQuick];
}

#pragma mark -
#pragma mark Instance Methods

-(void)replaceViewQuick
{
    [self beginShowView];
    [MainHUD.layer setOpacity:_pAlpha];
}

- (void)beginShowView
{
    [self updateLayout];
    
    if(!self.superview) [parentView addSubview:self];
    [self.layer setFrame:parentView.frame];
    [self addSubview:MainHUD];
    NSRect size = [self getCenterWithinRect:parentView.frame scale:1.0];
    [MainHUD.layer setFrame:size];
    
    _displaying = true;
    _activityCount++;
    
    [self addMask];
    
    [activityIndicator.layer setOpacity:1.0];
    [progressIndicator.layer setOpacity:1.0];
    [label.layer setOpacity:1.0];
}

-(void)finishHideView
{
    [MainHUD removeFromSuperview];
    [self removeFromSuperview];
    parentView = nil;
    _displaying = false;
    
    [self removeMask];

    [activityIndicator stopAnimation:nil];
}

- (void)showViewAnimated
{
    if(![parentView wantsLayer])
    {
        [parentView setWantsLayer:TRUE];
        [parentView setLayer:[CALayer layer]];
    }
    if(![MainHUD wantsLayer])
    {
        [MainHUD setWantsLayer:TRUE];
        [MainHUD setLayer:[CALayer layer]];
    }
    
    [self beginShowView];
    MainHUD.layer.opacity = 0.0;
    
    NSRect sizeBefore = [self getCenterWithinRect:parentView.frame scale:0.75];
    [MainHUD.layer setFrame:sizeBefore];
    
    _animatingShow = true;
    
    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.15f]
                     forKey:kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
        _animatingShow = false;
    }];

    [MainHUD.layer setFrame:[self getCenterWithinRect:parentView.frame scale:1.0]];
    [MainHUD.layer setOpacity:_pAlpha];
    [CATransaction commit];

    [self setNeedsDisplay:TRUE];
}

- (void)hideViewAnimated
{
    if(![parentView wantsLayer])
    {
        [parentView setWantsLayer:TRUE];
        [parentView setLayer:[CALayer layer]];
    }
    if(![MainHUD wantsLayer])
    {
        [MainHUD setWantsLayer:TRUE];
        [MainHUD setLayer:[CALayer layer]];
    }
    
    NSRect newSize = [self getCenterWithinRect:parentView.frame scale:0.75];
    
    //The ring doesnt resize easily. Clear it.
    [progressIndicator clear];

    _animatingDismiss = true;
    _animatingShow = true;

    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.15f] forKey:kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
        _animatingShow = false;
        if(MainHUD.layer.opacity == 0.0)
        {
            [self finishHideView];
            //[self updateLayout];
            [MainHUD addSubview:progressIndicator];
        }
    }];
    [activityIndicator.layer setOpacity:0.0];
    [label.layer setOpacity:0.0];
    [MainHUD.layer setFrame:newSize];
    [MainHUD.layer setOpacity:0.0];
    [CATransaction commit];

    [self setNeedsDisplay:TRUE];
}

- (void)popActivity
{
    _activityCount--;
    if(_activityCount == 0)
        [self hideViewAnimated];
}

#pragma mark -
#pragma mark Laying It Out

- (void)updateLayout
{
    [self setBackground];
    
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
    activityIndicator.frame = progressIndicator.frame = indicatorRect;
    
    CGFloat spaceOnTop = (stringHeight != 0) ? _pPadding/3 : 0;

    [progressIndicator setRingThickness:6];
    [progressIndicator sizeToFit];
    [activityIndicator setColor:[NSColor whiteColor]];
    
    pSize.width = popupWidth;
    pSize.height = iY+iH+_pPadding+spaceOnTop;//+(_pPadding/2);
    
    [self setAutoresizesSubviews:YES];
    [MainHUD setAutoresizesSubviews:YES];
    
    [self setNeedsDisplay:TRUE];
    [MainHUD setNeedsDisplay:TRUE];
}

- (void)setBackground
{
    CGColorRef bgcolor = CGColorCreateGenericRGB(0.05, 0.05, 0.05, _pAlpha);
    if(![MainHUD wantsLayer])
    {
        CALayer* bgLayer = [CALayer layer];
        [bgLayer setBackgroundColor:bgcolor];
        [bgLayer setCornerRadius:15.0];
        [MainHUD setWantsLayer:TRUE];
        [MainHUD setLayer:bgLayer];
    }
    else {
        [MainHUD.layer setBackgroundColor:bgcolor];
        [MainHUD.layer setCornerRadius:15.0];
    }
    
    if(![self layer]) {
        CALayer* bgLayer = [CALayer layer];
        [self setLayer:bgLayer];
        [self setWantsLayer:TRUE];
    }

    [self.layer setBackgroundColor:CGColorCreateGenericRGB(0, 0, 0, _backgroundAlpha)];

    [self setNeedsDisplay:TRUE];
}

#pragma mark -
#pragma mark Other

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

#pragma mark -

- (void)initializePopup
{
    self.autoresizingMask = NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin;
    MainHUD.autoresizingMask = NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin;
    
    MainHUD = [[NSView alloc] init];
    activityIndicator = [[DJActivityIndicator alloc] init];
    progressIndicator = [[DJProgressIndicator alloc] init];
    backgroundMask = [[NSButton alloc] init];
    label = [[NSTextField alloc] init];
    
    [self addSubview:MainHUD];
    [MainHUD addSubview:label];
    [MainHUD addSubview:activityIndicator];
    [MainHUD addSubview:progressIndicator];
    
    //----DEFAULT VALUES----
    
    _backgroundAlpha = 0.4;
    _actionsEnabled = FALSE;
    
    _pOffset = CGVectorMake(0, 0);
    _pAlpha = 0.9;
    _pPadding = 10;
    
    _indicatorSize = CGSizeMake(40, 40);
    _indicatorOffset = CGVectorMake(0, 0);
    
    _indicatorSize = CGSizeMake(40, 40);
    _indicatorOffset = CGVectorMake(0, 0);
    
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    
    label.font = [NSFont boldSystemFontOfSize:12.0];
    [label setTextColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.85]];
}

+ (DJProgressHUD *) instance
{
    static dispatch_once_t once;
    static DJProgressHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[self alloc] init];
        [sharedView initializePopup];
    });
    
    return sharedView;
}

@end
