//
//  NFSplitViewController.m
//  SplitView
//
//  Created by Alexander Cohen on 2014-10-28.
//  Copyright (c) 2014 BedroomCode. All rights reserved.
//

#import "NFSplitViewController.h"
#import "NFLayerBackedView.h"

NSString* const NFSplitViewControllerWillBeginLiveResizeNotification = @"NFSplitViewControllerWillBeginLiveResizeNotification";
NSString* const NFSplitViewControllerDidFinishLiveResizeNotification = @"NFSplitViewControllerDidFinishLiveResizeNotification";

@interface NFSplitViewControllerView : NFLayerBackedView

@property (nonatomic,assign) CGFloat vc2SizeBeforeCollpase;
@property (nonatomic,strong) NSMutableIndexSet* collapsedIndexes;
@property (nonatomic,weak) NFSplitViewController* controller;
@property (nonatomic,getter=isVertical) BOOL vertical;
@property (nonatomic,assign) CGFloat dividerThickness;

@end

@interface NFSplitViewController ()

@property (nonatomic,assign) BOOL isInTransition;
@property (nonatomic,strong) NFSplitViewControllerView* splitView;
@property (nonatomic,assign) BOOL isInAnimation;
@property (nonatomic,assign) BOOL isResizingWithDivider;

@end

@implementation NSViewController (NFSplitViewControllerView)

- (CGFloat)minimumLengthInSplitViewController:(NFSplitViewController*)splitViewController
{
    return 0;
}

- (CGFloat)maximumLengthInSplitViewController:(NFSplitViewController*)splitViewController
{
    return MAXFLOAT;
}

- (BOOL)canCollapseInSplitViewController:(NFSplitViewController*)splitViewController
{
    return YES;
}

- (NFSplitViewController*)splitViewController
{
    // is my mama a split view controller?
    if ( [self.parentViewController isKindOfClass:[NFSplitViewController class]] )
        return (NFSplitViewController*)self.parentViewController;
    
    // i'm a split view controller so use my parent or else my view will just return myself
    if ( [self isKindOfClass:[NFSplitViewController class]] )
        return self.view.superview.splitViewController;
    
    // ask my view to find it, i'm lazy
    return self.view.splitViewController;
}

@end

@implementation NSView (AKSplitViewController)

- (NFSplitViewController*)splitViewController
{
    // find a parent split view from a view
    NSView* v = self;
    while ( v && ![v isKindOfClass:[NFSplitViewControllerView class]] )
        v = v.superview;
    
    if ( [v isKindOfClass:[NFSplitViewControllerView class]] )
        return ((NFSplitViewControllerView*)v).controller;
    
    return nil;
}

@end

@implementation NFSplitViewControllerView

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    _dividerThickness = 1;
    _collapsedIndexes = [NSMutableIndexSet indexSet];
    return self;
}

- (CGRect)_splitterRect
{
    if ( self.controller.childViewControllers.count < 2 )
        return CGRectZero;
    
    NSUInteger          numController = self.controller.childViewControllers.count;
    NSViewController*   vc1 = numController > 0 ? self.controller.childViewControllers[0] : nil;
    
    if ( self.vertical )
    {
        return CGRectMake( 0, CGRectGetMaxY(vc1.view.frame)-2, self.bounds.size.width, self.dividerThickness+4 );
    }
    else
    {
        return CGRectMake( CGRectGetMaxX(vc1.view.frame)-2, 0, self.dividerThickness+4, self.bounds.size.height );
    }
    
    return CGRectZero;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    // not 1 click
    if ( theEvent.clickCount > 1 )
    {
        [super mouseDown:theEvent];
        return;
    }
    
    // do we have at least 2 vc's
    if ( self.controller.childViewControllers.count != 2 )
    {
        [super mouseDown:theEvent];
        return;
    }
    
    // not in resize cursor
    if ( !CGRectContainsPoint( [self _splitterRect], [self convertPoint:theEvent.locationInWindow fromView:nil] ) )
    {
        [super mouseDown:theEvent];
        return;
    }
    
    CGPoint locationInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
    CGFloat offset = self.vertical ? locationInView.y - [self _splitterRect].origin.y : locationInView.x - [self _splitterRect].origin.x;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFSplitViewControllerWillBeginLiveResizeNotification object:self.controller];
    
    self.controller.isResizingWithDivider = YES;
    
    // do the event pump drag
    BOOL pumpEvents = YES;
    while ( pumpEvents )
    {
        theEvent = [self.window nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        
        switch ( theEvent.type )
        {
            case NSLeftMouseDragged:
            {
                locationInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
                NSViewController*   vc = self.controller.childViewControllers[0];
                CGFloat             min1 = [vc minimumLengthInSplitViewController:self.controller];
                CGFloat             max1 = [vc maximumLengthInSplitViewController:self.controller];
                NSView*             v = vc.view;
                CGRect r = v.frame;
                if ( self.vertical )
                    r.size.height = MIN( max1, MAX( min1, locationInView.y - offset ) );
                else
                    r.size.width = MIN( max1, MAX( min1, locationInView.x - offset ) );
                v.frame = r;
                
                NSCursor* cursor = nil;
                
                if ( self.isVertical )
                {
                    if ( r.size.height <= min1 )
                    {
                        cursor = [NSCursor resizeDownCursor];
                    }
                    else if ( r.size.height >= max1 )
                    {
                        cursor = [NSCursor resizeUpCursor];
                    }
                    else
                    {
                        cursor = [NSCursor resizeUpDownCursor];
                    }
                }
                else
                {
                    if ( r.size.width <= min1 )
                    {
                        cursor = [NSCursor resizeRightCursor];
                    }
                    else if ( r.size.width >= max1 )
                    {
                        cursor = [NSCursor resizeLeftCursor];
                    }
                    else
                    {
                        cursor = [NSCursor resizeLeftRightCursor];
                    }
                }

                [cursor set];
                
                [self _performLayoutAnimated:NO resetBasedOnVC2:NO];
            }
                break;
                
            case NSLeftMouseUp:
            {
                [self setNeedsLayout:YES];
                [self.window invalidateCursorRectsForView:self];
                
                [[NSCursor currentSystemCursor] set];
                
                pumpEvents = NO;
            }
                break;
                
            default:
            {
            }
                break;
        }
    }
    
    self.controller.isResizingWithDivider = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFSplitViewControllerDidFinishLiveResizeNotification object:self.controller];
    
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    
    NSCursor* cursor = self.vertical ? [NSCursor resizeUpDownCursor] : [NSCursor resizeLeftRightCursor];
    [cursor setOnMouseEntered:YES];
    
    [self addCursorRect: [self _splitterRect] cursor:cursor];
}

- (void)setDividerThickness:(CGFloat)dividerThickness
{
    _dividerThickness = dividerThickness;
    [self setNeedsLayout:YES];
    [self layoutSubtreeIfNeeded];
    [self.window invalidateCursorRectsForView:self];
    
}

- (void)setVertical:(BOOL)vertical
{
    _vertical = vertical;
    [self setNeedsLayout:YES];
    [self layoutSubtreeIfNeeded];
    [self.window invalidateCursorRectsForView:self];
}

- (void)setVertical:(BOOL)vertical animated:(BOOL)animated completion:(void (^)(void))completion
{
    _vertical = vertical;
    
    if ( animated )
    {
        __weak typeof(self)weakMe = self;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            typeof(self)me = weakMe;
            [NSAnimationContext currentContext].allowsImplicitAnimation = YES;
            [me _performLayoutAnimated:YES resetBasedOnVC2:NO];
        } completionHandler:^{
            typeof(self)me = weakMe;
            [me.window invalidateCursorRectsForView:me];
            if ( completion )
                completion();
        }];
    }
    else
    {
        [self setNeedsLayout:YES];
        [self.window invalidateCursorRectsForView:self];
        if ( completion )
            completion();
    }
}

- (void)_performVerticalLayoutAnimated:(BOOL)animated resetBasedOnVC2:(BOOL)resetBasedOnVC2
{
    animated = animated || self.controller.splitViewController.isInAnimation;
    
    NSViewController*   vc1 = [self viewControllerAtIndex:0];
    NSViewController*   vc2 = [self viewControllerAtIndex:1];
    
    CGFloat             min1 = vc1 ? [vc1 minimumLengthInSplitViewController:self.controller] : 0;
    CGFloat             min2 = vc2 ? [vc2 minimumLengthInSplitViewController:self.controller] : 0;
    CGFloat             max1 = vc1 ? [vc1 maximumLengthInSplitViewController:self.controller] : 0;
    CGFloat             max2 = vc2 ? [vc2 maximumLengthInSplitViewController:self.controller] : 0;
    
    CGRect              frame1 = vc1.view.frame;
    CGRect              frame2 = vc2.view.frame;
    
    BOOL                vc1IsCollapsed = [self isViewControllerCollapsedAtIndex:0];
    BOOL                vc2IsCollapsed = [self isViewControllerCollapsedAtIndex:1];
    
    // set defaults
    if ( frame1.size.height < min1 )
        frame1.size.height = min1;
    if ( frame1.size.height > max1 )
        frame1.size.height = max1;
    
    if ( frame2.size.height < min2 )
        frame2.size.height = min2;
    if ( frame2.size.height > max2 )
        frame2.size.height = max2;
    
    // setup frame 1
    frame1.origin.x = 0;
    frame1.origin.y = 0;
    frame1.size.width = self.bounds.size.width;
    if ( frame1.size.height > self.bounds.size.height - self.dividerThickness )
        frame1.size.height = self.bounds.size.height - self.dividerThickness;
    
    if ( vc2IsCollapsed )
        frame1.size.height = self.bounds.size.height;
    else if ( resetBasedOnVC2 && !vc1IsCollapsed )
    {
        frame1.size.height = self.bounds.size.height - self.dividerThickness - self.vc2SizeBeforeCollpase;
    }
    
    // setup frame 2
    frame2.origin.x = 0;
    frame2.origin.y = vc1IsCollapsed ? 0 : CGRectGetMaxY(frame1) + self.dividerThickness;
    frame2.size.height = vc1IsCollapsed ? self.bounds.size.height : self.bounds.size.height - CGRectGetMinY(frame2);
    frame2.size.width = self.bounds.size.width;
    
    // apply frames
    if ( animated )
    {
        [[vc1.view animator] setFrame:frame1];
        [[vc2.view animator] setFrame:frame2];
    }
    else
    {
        vc1.view.frame = frame1;
        vc2.view.frame = frame2;
    }
}

- (void)_performHorizontalLayoutAnimated:(BOOL)animated resetBasedOnVC2:(BOOL)resetBasedOnVC2
{
    animated = animated || self.controller.splitViewController.isInAnimation;
    
    NSViewController*   vc1 = [self viewControllerAtIndex:0];
    NSViewController*   vc2 = [self viewControllerAtIndex:1];
    
    CGFloat             min1 = vc1 ? [vc1 minimumLengthInSplitViewController:self.controller] : 0;
    CGFloat             min2 = vc2 ? [vc2 minimumLengthInSplitViewController:self.controller] : 0;
    CGFloat             max1 = vc1 ? [vc1 maximumLengthInSplitViewController:self.controller] : 0;
    CGFloat             max2 = vc2 ? [vc2 maximumLengthInSplitViewController:self.controller] : 0;
    
    CGRect              frame1 = vc1.view.frame;
    CGRect              frame2 = vc2.view.frame;
    
    BOOL                vc1IsCollapsed = [self isViewControllerCollapsedAtIndex:0];
    BOOL                vc2IsCollapsed = [self isViewControllerCollapsedAtIndex:1];
    
    // set defaults
    if ( frame1.size.width < min1 )
        frame1.size.width = min1;
    if ( frame1.size.width > max1 )
        frame1.size.width = max1;
    
    if ( frame2.size.width < min2 )
        frame2.size.width = min2;
    if ( frame2.size.width > max2 )
        frame2.size.width = max2;
    
    // setup frame 1
    frame1.origin.x = 0;
    frame1.origin.y = 0;
    frame1.size.height = self.bounds.size.height;
    if ( frame1.size.width > self.bounds.size.width - self.dividerThickness )
        frame1.size.width = self.bounds.size.width - self.dividerThickness;
    
    if ( vc2IsCollapsed )
        frame1.size.width = self.bounds.size.width;
    else if ( resetBasedOnVC2 && !vc1IsCollapsed )
    {
        frame1.size.width = self.bounds.size.width - self.dividerThickness - self.vc2SizeBeforeCollpase;
    }
    
    // setup frame 2
    frame2.origin.x = vc1IsCollapsed ? 0 : CGRectGetMaxX(frame1) + self.dividerThickness;
    frame2.origin.y = 0;
    frame2.size.width = vc1IsCollapsed ? self.bounds.size.width : self.bounds.size.width - CGRectGetMinX(frame2);
    frame2.size.height = self.bounds.size.height;
    
    // apply frames
    if ( animated )
    {
        [[vc1.view animator] setFrame:frame1];
        [[vc2.view animator] setFrame:frame2];
    }
    else
    {
        vc1.view.frame = frame1;
        vc2.view.frame = frame2;
    }
}

- (void)_performLayoutAnimated:(BOOL)animated resetBasedOnVC2:(BOOL)resetBasedOnVC2
{
    if ( self.isVertical )
        [self _performVerticalLayoutAnimated:animated resetBasedOnVC2:resetBasedOnVC2];
    else
        [self _performHorizontalLayoutAnimated:animated resetBasedOnVC2:resetBasedOnVC2];
}

- (void)resizeChildViewcontrollers
{
    [self _performLayoutAnimated:NO resetBasedOnVC2:NO];
}

- (void)layout
{
    [self _performLayoutAnimated:NO resetBasedOnVC2:NO];
    [super layout];
}

- (NSViewController*)viewControllerAtIndex:(NSUInteger)index
{
    return self.controller.childViewControllers.count > index ? self.controller.childViewControllers[index] : nil;
}

- (void)collapseViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated completion:(void (^)(void))completion
{
    NSViewController* vc = [self viewControllerAtIndex:index];
    if ( !vc || ![vc canCollapseInSplitViewController:self.controller] )
        return;
    
    if ( [self isViewControllerCollapsedAtIndex:index] )
    {
        [self.collapsedIndexes removeIndex:index];
        
        vc.view.hidden = NO;
        
        if ( animated )
        {
            __weak typeof(self)weakMe = self;
            self.controller.isInAnimation = YES;
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                typeof(self)me = weakMe;
                [NSAnimationContext currentContext].allowsImplicitAnimation = YES;
                [me _performLayoutAnimated:YES resetBasedOnVC2: index == 1];
                me.controller.isInAnimation = NO;
            } completionHandler:^{
                if ( completion )
                    completion();
            }];
        }
        else
        {
            [self setNeedsLayout:YES];
            [self layoutSubtreeIfNeeded];
            if ( completion )
                completion();
        }
        
    }
    else
    {
        [self.collapsedIndexes addIndex:index];
        
        if ( index == 1 )
            self.vc2SizeBeforeCollpase = self.isVertical ? vc.view.frame.size.height : vc.view.frame.size.width;
        
        if ( animated )
        {
            __weak typeof(self)weakMe = self;
            self.controller.isInAnimation = YES;
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                typeof(self)me = weakMe;
                [NSAnimationContext currentContext].allowsImplicitAnimation = YES;
                [me _performLayoutAnimated:YES resetBasedOnVC2:NO];
                self.controller.isInAnimation = NO;
            } completionHandler:^{
                vc.view.hidden = YES;
                if ( completion )
                    completion();
            }];
        }
        else
        {
            vc.view.hidden = NO;
            [self setNeedsLayout:YES];
            [self layoutSubtreeIfNeeded];
            if ( completion )
                completion();
        }
        
    }
}

- (BOOL)isViewControllerCollapsedAtIndex:(NSUInteger)index
{
    return [self.collapsedIndexes containsIndex:index];
}

@end

@implementation NFSplitViewController

- (void)setVertical:(BOOL)vertical
{
    [self setVertical:vertical animated:NO completion:nil];
}

- (void)setVertical:(BOOL)vertical animated:(BOOL)animated completion:(void (^)(void))completion
{
    (void)self.view;
    [self.splitView setVertical:vertical animated:animated completion:completion];
}

- (BOOL)isVertical
{
    (void)self.view;
    return self.splitView.isVertical;
}

+ (CGFloat)dividerThickness
{
    return 1;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    return self;
}

- (void)loadView
{
    self.view = [[NFLayerBackedView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.splitView = [[NFSplitViewControllerView alloc] initWithFrame:self.view.bounds];
    self.splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.splitView.backgroundColor = [NSColor lightGrayColor];
    self.splitView.controller = self;
    [self.view addSubview:self.splitView];
    
    for ( NSViewController* cntlr in self.childViewControllers )
        [self.splitView addSubview:cntlr.view];
}

- (void)setDividerColor:(NSColor *)dividerColor
{
    (void)self.view;
    self.splitView.backgroundColor = dividerColor;
}

- (NSColor*)dividerColor
{
    (void)self.view;
    return self.splitView.backgroundColor;
}

- (void)setDividerThickness:(CGFloat)dividerThickness
{
    (void)self.view;
    self.splitView.dividerThickness = dividerThickness;
}

- (CGFloat)dividerThickness
{
    (void)self.view;
    return self.splitView.dividerThickness;
}

- (void)collapseViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated completion:(void (^)(void))completion
{
    [self.splitView collapseViewControllerAtIndex:index animated:animated completion:completion];
}

- (BOOL)isViewControllerCollapsedAtIndex:(NSUInteger)index
{
    return [self.splitView isViewControllerCollapsedAtIndex:index];
}

- (NSViewController*)viewControllerAtIndex:(NSUInteger)index
{
    return self.childViewControllers.count > index ? self.childViewControllers[index] : nil;
}

- (void)transitionFromViewControllerAtIndex:(NSUInteger)index toViewController:(NSViewController*)viewController
{
    if ( ![self viewControllerAtIndex:index] )
    {
        [self insertChildViewController:viewController atIndex:index];
    }
    else
    {
        self.isInTransition = YES;
        [self addChildViewController:viewController];
        NSViewController* srcVC = [self viewControllerAtIndex:index];
        viewController.view.frame = srcVC.view.frame;
        
        __weak typeof(self)weakMe = self;
        [self transitionFromViewController:srcVC toViewController:viewController options:NSViewControllerTransitionCrossfade completionHandler:^{
            typeof(self)me = weakMe;
            [srcVC removeFromParentViewController];
            me.isInTransition = NO;
        }];
    }
}

- (void)insertChildViewController:(NSViewController *)childViewController atIndex:(NSInteger)index
{
    if ( self.isInTransition )
    {
        [super insertChildViewController:childViewController atIndex:index];
        return;
    }
    
    NSAssert( self.childViewControllers.count < 2, @"A SplitViewController can only have 2 child view controllers", nil );
    
    [super insertChildViewController:childViewController atIndex:index];
    
    if ( ![self isViewLoaded] )
        return;
    
    NSView* rel = nil;
    if ( index > 0 )
        rel = self.splitView.subviews[index-1];
    
    [self.splitView addSubview:childViewController.view positioned:NSWindowAbove relativeTo:rel];
    [self.splitView setNeedsLayout:YES];
    [self.view.window invalidateCursorRectsForView:self.splitView];
}

- (void)removeChildViewControllerAtIndex:(NSInteger)index
{
    [super removeChildViewControllerAtIndex:index];
    
    if ( self.isInTransition || ![self isViewLoaded] )
        return;
    
    NSView* sub = self.splitView.subviews[index];
    [sub removeFromSuperview];
    [self.view.window invalidateCursorRectsForView:self.splitView];
}

- (void)resizeChildViewcontrollers
{
    [self.splitView resizeChildViewcontrollers];
}

@end
