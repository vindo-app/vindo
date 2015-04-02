//
//  ImageAndTextCell.m
//  Vindo
//
//  Created by Theodore Dubois on 4/1/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ImageAndTextCell.h"

@implementation ImageAndTextCell

- (instancetype)initTextCell:(NSString *)aString {
    if (self = [super initTextCell:aString]) {
        // nothing needs to be done...yet
    }
    return self;
}

// Returns the rect where the field editor should appear. Cut off the image from the provided rect.
- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect imageFrame;
    
    NSDivideRect(theRect, &imageFrame, &theRect, _image.size.width + 3, NSMinXEdge);
    imageFrame.size = _image.size;
    imageFrame.origin.x += 3;
    imageFrame.origin.y -= 1;
    
    imageFrame.origin.y += ceil((theRect.size.height - imageFrame.size.height) / 2);
    
    // put two pixels on the top and bottom of the text
    NSRect result = theRect;
    result.origin.x += 2;
    result.origin.y += 2;
    result.size.height += 4;
    return result;
}

- (void)selectWithFrame:(NSRect)aRect
                 inView:(NSView *)controlView
                 editor:(NSText *)textObj
               delegate:(id)anObject
                  start:(NSInteger)selStart
                 length:(NSInteger)selLength {
    [super selectWithFrame:[self titleRectForBounds:aRect]
                    inView:controlView
                    editor:textObj
                  delegate:anObject
                     start:selStart
                    length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect newCellFrame = cellFrame;

    NSSize imageSize;
    NSRect imageFrame;
    
    imageSize = _image.size;
    NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
    
    if ([self drawsBackground]) {
        [[self backgroundColor] set];
        NSRectFill(imageFrame);
    }
    
    imageFrame.origin.y += 2;
    imageFrame.size = imageSize;
    
    [self.image drawInRect:imageFrame
                  fromRect:NSZeroRect
                 operation:NSCompositeSourceOver
                  fraction:1.0
            respectFlipped:YES
                     hints:nil];
    
    [super drawWithFrame:newCellFrame inView:controlView];
}

- (NSSize)cellSize{
    NSSize cellSize = [super cellSize];
    cellSize.width += self.image.size.width + 3;
    return cellSize;
}

@end
