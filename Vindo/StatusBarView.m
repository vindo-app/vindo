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
    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:self.highlighted];
    NSImage *tintedIcon = self.tintedIcon;
    NSRect centeredIcon;
    centeredIcon.size = tintedIcon.size;
    centeredIcon.origin.x = (self.bounds.size.width - tintedIcon.size.width)/2;
    centeredIcon.origin.y = (self.bounds.size.height - tintedIcon.size.height)/2;
    [tintedIcon drawInRect:centeredIcon];
}

- (NSImage *)tintedIcon {
    NSImage *tintedIcon = [self.image copy];
    tintedIcon.template = NO;
    [tintedIcon lockFocus];
    if (self.highlighted)
        [[NSColor whiteColor] set];
    else {
        if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_10)
            [[NSColor labelColor] set];
        else
            [[NSColor blackColor] set];
    }
    NSRectFillUsingOperation((NSRect){.origin = NSZeroPoint, .size = tintedIcon.size}, NSCompositeSourceAtop);
    [tintedIcon unlockFocus];
    return tintedIcon;
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
