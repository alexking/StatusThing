//
//  AKStatusItemView.h
//  StatusThing
//
//  Created by Alex King on 11/27/13.
//  Copyright (c) 2013 Alex King. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AKStatusItemViewDelegate <NSObject>
@optional
-(void) mouseDownWithEvent: (NSEvent *)event;
-(void) mouseEnteredWithEvent: (NSEvent *)event; 
@end

@interface AKStatusItemView : NSView <NSMenuDelegate>

@property (nonatomic) bool showIcon;
@property bool menuIsVisible;
@property (nonatomic) NSString *title; 

@property NSTrackingArea *tracking;

- (void)menuWillOpen:(NSMenu *)menu;
- (void)menuDidClose:(NSMenu *)menu;

- (void) mouseEntered:(NSEvent *)event;

- (id)initWithStatusItem: (NSStatusItem *)statusItem;

@property (weak) id<AKStatusItemViewDelegate> delegate;
@property (weak) NSStatusItem *statusItem; 

@end
