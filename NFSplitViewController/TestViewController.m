//
//  TestViewController.m
//  SplitView
//
//  Created by Alexander Cohen on 2014-10-28.
//  Copyright (c) 2014 BedroomCode. All rights reserved.
//

#import "TestViewController.h"
#import "NFLayerBackedView.h"
#import "NFSplitViewController.h"

@interface TestViewController ()

@property (nonatomic,strong) NSTextField* textField;

@end

@implementation TestViewController

- (void)loadView
{
    self.view = [[NFLayerBackedView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.borderColor = [NSColor redColor];
    self.borderWidth = 1;
    
    self.textField = [[NSTextField alloc] initWithFrame:CGRectInset(self.view.bounds, 10, 10)];
    self.textField.layer.borderWidth = 1;
    self.textField.layer.borderColor = [NSColor blackColor].CGColor;
    self.textField.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.textField.stringValue = _name ? _name : @"";
    self.textField.enabled = NO;
    self.textField.editable = NO;
    [self.view addSubview:self.textField];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    ((NFLayerBackedView*)self.view).backgroundColor = backgroundColor;
}

- (NSColor*)backgroundColor
{
    return ((NFLayerBackedView*)self.view).backgroundColor;
}

- (void)setBorderColor:(NSColor *)borderColor
{
    ((NFLayerBackedView*)self.view).borderColor = borderColor;
}

- (NSColor*)borderColor
{
    return ((NFLayerBackedView*)self.view).borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    ((NFLayerBackedView*)self.view).borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return ((NFLayerBackedView*)self.view).borderWidth;
}

- (void)setName:(NSString *)name
{
    _name = [name copy];
    self.textField.stringValue = _name ? _name : @"";
}

- (CGFloat)minimumLengthInSplitViewController:(NFSplitViewController*)splitViewController
{
    return 100;
}

- (CGFloat)maximumLengthInSplitViewController:(NFSplitViewController *)splitViewController
{
    return 300;
}

@end
