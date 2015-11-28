//
//  StatusBarView.h
//  Vindo
//
//  Created by Theodore Dubois on 11/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusBarView : NSView

@property NSStatusItem *statusItem;

@property NSImage *image;

@property (getter=isHighlighted) BOOL highlighted;

@property id target;
@property SEL action;

@end
