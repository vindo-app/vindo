//
//  StatusBarView.m
//  Vindo
//
//  Created by Theodore Dubois on 11/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StatusBarView.h"

@implementation StatusBarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:self.highlighted];

    CGFloat iconX = roundf((self.bounds.size.width - self.image.size.width) / 2);
    CGFloat iconY = roundf((self.bounds.size.height - self.image.size.height) / 2);
    [self.image drawAtPoint:NSMakePoint(iconX, iconY)
                   fromRect:NSZeroRect
                  operation:NSCompositeSourceOver
                   fraction:1.0];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
