//
//  NSButtonCell+MultilineButtons.m
//  Vindo
//
//  Created by Theodore Dubois on 12/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "NSButtonCell+MultilineButtons.h"

@implementation NSButtonCell (MultilineButtons)

// Code from Stack Overflow.
- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:[title.string stringByReplacingOccurrencesOfString:@" " withString:@"\n"]];
    NSFont *sysFont = [NSFont systemFontOfSize:10];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                sysFont, NSFontAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    NSSize textSize = [as.string sizeWithAttributes:attributes];
    NSRect textBounds = NSMakeRect(0, 0, textSize.width, textSize.height);
    // using frame argument seems to produce text in wrong place
    NSRect f = NSMakeRect(0, (controlView.frame.size.height - textSize.height) / 2, controlView.frame.size.width, textSize.height);
    [as.string drawInRect:f withAttributes:attributes];
    return textBounds; // not sure what rectangle to return or what is done with it
}

@end
