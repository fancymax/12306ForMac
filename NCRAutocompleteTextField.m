//
//  NCAutocompleteTextView.m
//  Example
//
//  Created by Daniel Weber on 9/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "NCRAutocompleteTextField.h"


#define MAX_RESULTS 10

#define HIGHLIGHT_STROKE_COLOR [NSColor selectedMenuItemColor]
#define HIGHLIGHT_FILL_COLOR [NSColor selectedMenuItemColor]
#define HIGHLIGHT_RADIUS 0.0
#define INTERCELL_SPACING NSMakeSize(20.0, 3.0)

#define WORD_BOUNDARY_CHARS [[NSCharacterSet alphanumericCharacterSet] invertedSet]

#define POPOVER_WIDTH 250.0
#define POPOVER_PADDING 0.0

//#define POPOVER_APPEARANCE NSAppearanceNameVibrantDark
#define POPOVER_APPEARANCE NSAppearanceNameVibrantLight

#define POPOVER_FONT [NSFont fontWithName:@"Menlo" size:12.0]
// The font for the characters that have already been typed
#define POPOVER_BOLDFONT [NSFont fontWithName:@"Menlo-Bold" size:13.0]
#define POPOVER_TEXTCOLOR [NSColor blackColor]

#pragma mark -

@interface NCRAutocompleteTableRowView : NSTableRowView
@end
@implementation NCRAutocompleteTableRowView
- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 0.5, 0.5);
        [HIGHLIGHT_STROKE_COLOR setStroke];
        [HIGHLIGHT_FILL_COLOR setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:HIGHLIGHT_RADIUS yRadius:HIGHLIGHT_RADIUS];
        [selectionPath fill];
        [selectionPath stroke];
    }
}
- (NSBackgroundStyle)interiorBackgroundStyle {
    if (self.isSelected) {
        return NSBackgroundStyleDark;
    } else {
        return NSBackgroundStyleLight;
    }
}
@end

#pragma mark -

@interface NCRAutocompleteTextField ()
@property (nonatomic, strong) NSPopover *autocompletePopover;
@property (nonatomic, weak) NSTableView *autocompleteTableView;
@property (nonatomic, strong) NSArray *matches;
// Used to highlight typed characters and insert text
@property (nonatomic, copy) NSString *substring;
@end

@implementation NCRAutocompleteTextField

- (void)awakeFromNib {
    // Make a table view with 1 column and enclosing scroll view. It doesn't
    // matter what the frames are here because they are set when the popover
    // is displayed
    NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"text"];
    [column1 setEditable:NO];
    [column1 setWidth:POPOVER_WIDTH - 2 * POPOVER_PADDING];

    NSTableView *tableView = [[NSTableView alloc] initWithFrame:NSZeroRect];
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [tableView setBackgroundColor:[NSColor clearColor]];
    [tableView setRowSizeStyle:NSTableViewRowSizeStyleSmall];
    [tableView setIntercellSpacing:INTERCELL_SPACING];
    [tableView setHeaderView:nil];
    [tableView setRefusesFirstResponder:YES];
    [tableView setTarget:self];
    [tableView setDoubleAction:@selector(insert:)];
    [tableView addTableColumn:column1];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    self.autocompleteTableView = tableView;

    NSScrollView *tableScrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [tableScrollView setDrawsBackground:NO];
    [tableScrollView setDocumentView:tableView];
    [tableScrollView setHasVerticalScroller:YES];
    
    NSView *contentView = [[NSView alloc] initWithFrame:NSZeroRect];
    [contentView addSubview:tableScrollView];
    
    NSViewController *contentViewController = [[NSViewController alloc] init];
    [contentViewController setView:contentView];
    
    self.autocompletePopover = [[NSPopover alloc] init];
    self.autocompletePopover.appearance = [NSAppearance appearanceNamed:POPOVER_APPEARANCE];
    self.autocompletePopover.animates = NO;
    self.autocompletePopover.contentViewController = contentViewController;
    
    self.matches = [NSMutableArray array];
}

- (void)keyUp:(NSEvent *)theEvent {
    NSInteger row = self.autocompleteTableView.selectedRow;
    BOOL shouldComplete = YES;
    switch (theEvent.keyCode) {
        case 51:
            // Delete
            [self.autocompletePopover close];
            shouldComplete = NO;
            break;
        case 53:
            // Esc
            if (self.autocompletePopover.isShown)
                [self.autocompletePopover close];
            return; // Skip default behavior
        case 125:
            // Down
            if (self.autocompletePopover.isShown) {
                [self.autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row+1] byExtendingSelection:NO];
                [self.autocompleteTableView scrollRowToVisible:self.autocompleteTableView.selectedRow];
                return; // Skip default behavior
            }
            break;
        case 126:
            // Up
            if (self.autocompletePopover.isShown) {
                [self.autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row-1] byExtendingSelection:NO];
                [self.autocompleteTableView scrollRowToVisible:self.autocompleteTableView.selectedRow];
                return; // Skip default behavior
            }
            break;
        case 36:
        case 48:
            // Return or tab
            if (self.autocompletePopover.isShown) {
                [self insert:self];
                return; // Skip default behavior
            }
        case 49:
            // Space
            if (self.autocompletePopover.isShown) {
                [self.autocompletePopover close];
            }
            break;
    }
    [super keyUp:theEvent];
    if (shouldComplete) {
        [self complete:self];
    }
}

- (void)insert:(id)sender {
    if (self.autocompleteTableView.selectedRow >= 0 && self.autocompleteTableView.selectedRow < self.matches.count) {
        NSString *string = [self.matches objectAtIndex:self.autocompleteTableView.selectedRow];
        [self setStringValue:string];
    }
    [self.autocompletePopover close];
}


- (void)complete:(id)sender {
    NSUInteger lengthOfWord = self.stringValue.length;
    NSRange substringRange = NSMakeRange(0, lengthOfWord);
    
    if (substringRange.length == 0 || lengthOfWord == 0) {
        // This happens when we just started a new word or if we have already typed the entire word
        [self.autocompletePopover close];
        return;
    }
    
    NSInteger index = 0;
    self.matches = [self completionsForPartialWordRange:substringRange indexOfSelectedItem:&index];
    
    if (self.matches.count > 0) {
        [self.autocompleteTableView reloadData];
        
        [self.autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [self.autocompleteTableView scrollRowToVisible:index];
        
        // Make the frame for the popover. We want it to shrink with a small number
        // of items to autocomplete but never grow above a certain limit when there
        // are a lot of items. The limit is set by MAX_RESULTS.
        NSInteger numberOfRows = MIN(self.autocompleteTableView.numberOfRows, MAX_RESULTS);
        CGFloat height = (self.autocompleteTableView.rowHeight + self.autocompleteTableView.intercellSpacing.height) * numberOfRows + 2 * POPOVER_PADDING;
        NSRect frame = NSMakeRect(0, 0, POPOVER_WIDTH, height);
        [self.autocompleteTableView.enclosingScrollView setFrame:NSInsetRect(frame, POPOVER_PADDING, POPOVER_PADDING)];
        [self.autocompletePopover setContentSize:NSMakeSize(NSWidth(frame), NSHeight(frame))];
        
        // We want to find the middle of the first character to show the popover.
        // firstRectForCharacterRange: will give us the rect at the begeinning of
        // the word, and then we need to find the half-width of the first character
        // to add to it.
        NSRect rect = [self visibleRect];
        rect = [self.window convertRectFromScreen:rect];
        rect = [self convertRect:rect fromView:nil];
        NSString *firstChar = [self.substring substringToIndex:1];
        NSSize firstCharSize = [firstChar sizeWithAttributes:@{NSFontAttributeName:self.font}];
        rect.size.width = firstCharSize.width;
        
        [self.autocompletePopover showRelativeToRect:rect ofView:self preferredEdge:NSMaxYEdge];
    } else {
        [self.autocompletePopover close];
    }
}

- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    if ([self.delegate respondsToSelector:@selector(textField:completions:forPartialWordRange:indexOfSelectedItem:)]) {
        return [self.delegate textField:self completions:@[] forPartialWordRange:charRange indexOfSelectedItem:index];
    }
    return @[];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.matches.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] initWithFrame:NSZeroRect];
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [textField setBezeled:NO];
        [textField setDrawsBackground:NO];
        [textField setEditable:NO];
        [textField setSelectable:NO];
        [cellView addSubview:textField];
        cellView.textField = textField;
        cellView.identifier = @"MyView";
    }
    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:self.matches[row] attributes:@{NSFontAttributeName:POPOVER_FONT, NSForegroundColorAttributeName:POPOVER_TEXTCOLOR}];
    
    if (self.substring) {
        NSRange range = [as.string rangeOfString:self.substring options:NSAnchoredSearch|NSCaseInsensitiveSearch];
        [as addAttribute:NSFontAttributeName value:POPOVER_BOLDFONT range:range];
    }
    
    [cellView.textField setAttributedStringValue:as];
    
    return cellView;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[NCRAutocompleteTableRowView alloc] init];
}

@end
