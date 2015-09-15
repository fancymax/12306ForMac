/*
     File: LinkTextFieldCell.m 
 Abstract: Custom NSTextFieldCell to handle tracking and drawing links. 
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2013 Apple Inc. All Rights Reserved. 
  
 */

#import "LinkTextFieldCell.h"

@implementation LinkTextFieldCell

- (id)copyWithZone:(NSZone *)zone {
    
    LinkTextFieldCell *result = [super copyWithZone:zone];
    result->_linkClickedHandler = [_linkClickedHandler copy];
    return result;
}


// Our cell wants to work like a button, and wants to keep tracking until the mouse is released up
+ (BOOL)prefersTrackingUntilMouseUp {
    
    return YES;
}

// Text cells in NSTableView's normally don't "track the mouse", since they don't resond to clicks. 
// Wait! What about editing? Well, that is done via the NSFieldEditor which handles the clicks/selection/etc.
//
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    
    NSUInteger hitTestResult = [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
    // If we hit on content (ie: text, and not whitespace), then we go ahead and say we want to track
    if ((hitTestResult & NSCellHitContentArea) != 0) {
        hitTestResult |= NSCellHitTrackableArea;
    }
    return hitTestResult;
}

- (void)_setAttributedStringTextColor:(NSColor *)color {
    
    NSMutableAttributedString *attrValue = [[self attributedStringValue] mutableCopy];
    NSRange range = NSMakeRange(0, [attrValue length]);
    [attrValue addAttribute:NSForegroundColorAttributeName value:color range:range];
    [self setAttributedStringValue:attrValue];
}

// Factor link click handling into own method - used by tracking and accessibility
- (void)_handleLinkClick {
    
    NSAttributedString *attrValue = [self attributedStringValue];
    NSURL *link = [attrValue attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    if (link != nil && _linkClickedHandler != nil) {
	// We do have a link -- open it!
	_linkClickedHandler(link, self);
    }
}

// Override tracking to handle the link click -- while we are tracking we change the link
// text color to something different to let the user have some feedback that they are
// clicking on something.
//
// Ideally we want to override stopTracking:at:inView:mouseIsUp:, but we also need to know
// the cellFrame to find out if the user clicked on the content or not.
//
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    
    BOOL result = YES;
    // Did we click on the text? We will use the hit testing routine to see if we hit content -- for text cells, that means the text.
    NSUInteger hitTestResult = [self hitTestForEvent:theEvent inRect:cellFrame ofView:controlView];
    if ((hitTestResult & NSCellHitContentArea) != 0) {
        // Give the user some feedback by changing the text color
        [self _setAttributedStringTextColor:[NSColor redColor]];
        // Do the tracking until mouse up
        result = [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
        // Now we grab the latest event, in case the user moved the mouse in the normal
        // tracking loop, and hit test again
        theEvent = [NSApp currentEvent];
        hitTestResult = [self hitTestForEvent:theEvent inRect:cellFrame ofView:controlView];
        if ((hitTestResult & NSCellHitContentArea) != 0) {
            [self _handleLinkClick];
        }
    }
    return result;
}

// Here's a nice trick -- we want to flip the text color to not be blue when the row is
// selected (ie: has a dark background style)
//
- (void)setBackgroundStyle:(NSBackgroundStyle)style {
    
    [super setBackgroundStyle:style];
    if (style == NSBackgroundStyleDark) {
        [self _setAttributedStringTextColor:[NSColor whiteColor]];
    }
}

#pragma mark - Accessibility support

// Add an AXPress action to list of actions we support, when asked to perform, handle the link click.

- (NSArray *)accessibilityActionNames {
    
    return [[super accessibilityActionNames] arrayByAddingObject:NSAccessibilityPressAction];
}

- (void)accessibilityPerformAction:(NSString *)action {
    
    if ([action isEqualToString:NSAccessibilityPressAction]) {
        [self _handleLinkClick];
    } else {
        [super accessibilityPerformAction:action];
    }
}

@end
