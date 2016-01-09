//
//  NSButtonCell+MultilineButtons.m
//  Vindo
//
//  Created by Theodore Dubois on 12/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuButtonCell.h"

// kludge so I can compile this on mavericks
@interface NSColor (CompilingOnMavericks)
+ (NSColor *)labelColor;
@end
#define NSAppKitVersionNumber10_9 1265
#define NSCenterTextAlignment 2

@implementation StartMenuButtonCell : NSButtonCell

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    self.highlightsBy = NSPushInCellMask;
    return self;
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSColor *textColor;
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9) { // mavericks or before
        textColor = [NSColor controlTextColor];
    } else {
        textColor = [NSColor labelColor];
    }
    
    // push frame down a few pixels
    frame.origin.y += 5;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSCenterTextAlignment;
    
    title = [[NSAttributedString alloc] initWithString:title.string
                                            attributes:@{
                                                         NSFontAttributeName: [NSFont systemFontOfSize:12],
                                                         NSForegroundColorAttributeName: textColor,
                                                         NSParagraphStyleAttributeName: paragraphStyle,
                                                         }];
    [title drawInRect:frame];
    return frame;
}

@end
