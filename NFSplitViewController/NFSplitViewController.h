//
//  NFSplitViewController.h
//  SplitView
//
//  Created by Alexander Cohen on 2014-10-28.
//  Copyright (c) 2014 BedroomCode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* const NFSplitViewControllerWillBeginLiveResizeNotification;
extern NSString* const NFSplitViewControllerDidFinishLiveResizeNotification;

@interface NFSplitViewController : NSViewController

- (void)collapseViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated completion:(void (^)(void))completion;
- (BOOL)isViewControllerCollapsedAtIndex:(NSUInteger)index;

@property (nonatomic,getter=isVertical) BOOL vertical;
- (void)setVertical:(BOOL)vertical animated:(BOOL)animated completion:(void (^)(void))completion;

@property (nonatomic,strong) NSColor* dividerColor;
@property (nonatomic,assign) CGFloat dividerThickness;

@property (nonatomic,readonly) BOOL isResizingWithDivider;

- (void)transitionFromViewControllerAtIndex:(NSUInteger)index toViewController:(NSViewController*)viewController;

- (void)resizeChildViewcontrollers;

@end

@interface NSViewController (AKSplitViewController)

- (CGFloat)minimumLengthInSplitViewController:(NFSplitViewController*)splitViewController;
- (CGFloat)maximumLengthInSplitViewController:(NFSplitViewController*)splitViewController;
- (BOOL)canCollapseInSplitViewController:(NFSplitViewController*)splitViewController;

@property (nonatomic,readonly) NFSplitViewController* splitViewController;

@end

@interface NSView (AKSplitViewController)

@property (nonatomic,readonly) NFSplitViewController* splitViewController;

@end