//
//  AKStatusItemView.m
//  StatusThing
//
//  Created by Alex King on 11/27/13.
//  Copyright (c) 2013 Alex King. All rights reserved.
//

#import "AKStatusItemView.h"

@implementation AKStatusItemView

- (id)initWithStatusItem: (NSStatusItem *)item
{
    self = [super init];
    if (self) {
        
        [self updateSize];
        
        self.statusItem = item;
        
        [self.statusItem.menu setDelegate: self];

    }
    
    return self;
}

/*! Set the text to be displayed */
- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [self updateSize];
}

- (void)setShowIcon:(bool)showIcon
{
    _showIcon = showIcon;
    
    [self updateSize];
}

- (void)updateSize
{
    
    if (self.showIcon)
    {
        
        NSImage *image = [NSImage imageNamed: @"plug"];
        [self setFrameSize: NSMakeSize([image size].width + 6, 22)];
        
    } else {
        
        NSSize s = [self.title sizeWithAttributes: [self stringAttributes]];
        [self setFrameSize: NSMakeSize( ((int) s.width) + 12, 22)];
        
    }
    
    [self setNeedsDisplay: YES];

    
}

- (void)drawRect:(NSRect)dirtyRect
{

	[super drawRect:dirtyRect];
    
    // Handle the blue background
    // If the menu is open, then display our blue/white/black scheme
    if (self.menuIsVisible)
    {
        // Fill the entire space with the blue selectedMenuItemColor
        [[NSColor selectedMenuItemColor] set];
        NSRectFill([self frame]);
        
    }
    
    if (self.showIcon)
    {
        
        NSImage *image;
        
        if (self.menuIsVisible)
        {
            image = [NSImage imageNamed: @"plug-white"];
        } else {
            image = [NSImage imageNamed: @"plug"];
        }
        
        [image drawInRect: NSMakeRect(3.0, 3.0, [image size].width, [image size].height)];
        
    } else {
        
        NSMutableDictionary *textFormatting = [[self stringAttributes] mutableCopy];
        
        textFormatting[NSForegroundColorAttributeName] = [NSColor whiteColor];
        
        // If the menu is open, then display our white/black scheme
        if (self.menuIsVisible)
        {
            textFormatting[NSForegroundColorAttributeName] = [NSColor blackColor];
            
            [[NSColor whiteColor] set];
        } else {
            [[NSColor blackColor] set];
        }
        
        NSBezierPath *bg = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(3.0, 3.0, ([self frame].size.width - 6.0), 17)
                                                           xRadius: 3.0
                                                           yRadius: 3.0];
        
        [bg fill];
        
        if (self.menuIsVisible)
        {
            [[NSColor whiteColor] set];
        } else {
            [[NSColor blackColor] set];
        }
        
        [self.title drawInRect: NSMakeRect(6.0, -1.0, [self frame].size.width, [self frame].size.height ) withAttributes: textFormatting];
        
    }
 
}

- (NSDictionary *)stringAttributes
{
    return @{ NSFontAttributeName : [NSFont menuBarFontOfSize: 13] };
}

- (void)mouseDown:(NSEvent *)event
{

    self.menuIsVisible = YES;
    [self setNeedsDisplay: YES];

    [self.statusItem popUpStatusItemMenu: self.statusItem.menu];

    if ([self.delegate respondsToSelector: @selector(mouseDownWithEvent:)])
    {
        [self.delegate mouseDownWithEvent: event];
    }

}

- (void)menuWillOpen:(NSMenu *)menu
{
    self.menuIsVisible = YES;
    [self setNeedsDisplay: YES];
}

- (void)menuDidClose:(NSMenu *)menu

{
    self.menuIsVisible = NO;
    [self setNeedsDisplay: YES];
}

- (void)updateTrackingAreas
{
 
    // If we've had a tracking area before, we'll need to remove it
    if (self.tracking != nil)
    {
        [self removeTrackingArea: self.tracking];
    }
    
    // Create the tracking area with our updated bounds
    self.tracking = [[NSTrackingArea alloc] initWithRect: [self bounds]
                                                        options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways)
                                                          owner: self
                                                       userInfo: nil];

    
    // Add the area
    [self addTrackingArea: self.tracking];
    
}

- (void) mouseEntered:(NSEvent *)event
{
    
    if ([self.delegate respondsToSelector: @selector(mouseEnteredWithEvent:)])
    {
        [self.delegate mouseEnteredWithEvent: event];
    }
    
}

@end
