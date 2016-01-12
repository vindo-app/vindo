//
//  StatusBarView.m
//  Vindo
//
//  Created by Theodore Dubois on 11/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StatusBarView.h"

@interface StatusBarView ()

@property NSImageCell *cell;

@end

@implementation StatusBarView

- (id)initWithImage:(NSImage *)image statusItem:(NSStatusItem *)statusItem {
    if (self = [super init]) {
        self.image = image;
        self.cell = [[NSImageCell alloc] initImageCell:image];
        self.cell.backgroundStyle = NSBackgroundStyleDark;
        self.statusItem = statusItem;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:self.highlighted];
 
    if (self.highlighted || [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"]  isEqualToString: @"Dark"]) {
        [self.cell drawWithFrame:self.bounds
                          inView:self];
    } else {
        CGFloat iconX = (self.bounds.size.width - self.image.size.width) / 2;
        CGFloat iconY = (self.bounds.size.height - self.image.size.height) / 2;
        [self.image drawAtPoint:NSMakePoint(iconX, iconY)
                       fromRect:NSZeroRect
                      operation:NSCompositeSourceOver
                       fraction:1.0];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
