//
//  NSButtonCell+MultilineButtons.m
//  Vindo
//
//  Created by Theodore Dubois on 12/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuButtonCell.h"

@implementation StartMenuButtonCell : NSButtonCell

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    self.highlightsBy = NSPushInCellMask;
    return self;
}


- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSColor *textColor;
    if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_10) {
        textColor = [NSColor controlTextColor];
    } else {
        textColor = [NSColor labelColor];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
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
