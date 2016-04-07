//
//  WorkingCollectionView.m
//  Vindo
//
//  Created by Theodore Dubois on 1/14/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StartMenuCollectionView.h"
#import "StartMenuItem.h"
#import "StartMenuController.h"
#import "StartMenu.h"

@interface StartMenuCollectionView ()

@property NSUInteger dragStartIndex;
@property NSUInteger dragIndex;

@property NSWindow *dragAnimation;

@property IBOutlet NSObjectController *menuContainer;

@property IBOutlet NSSearchField *sf;

@end

@implementation StartMenuCollectionView

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    self = [super awakeAfterUsingCoder:aDecoder];
    [self registerForDraggedTypes:@[StartMenuItemPasteboardType]];
    self.dragStartIndex = self.dragIndex = NSNotFound;
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)info {
    if (self.sf.stringValue.length != 0)
        return NSDragOperationNone;
    
    BOOL justStarted = self.dragStartIndex == NSNotFound;
    if (justStarted)
        self.dragStartIndex = self.dragIndex = [self indexForWindowPoint:info.draggingLocation];
    else
        self.dragIndex = self.dragStartIndex;
    NSView *view = [self itemAtIndex:self.dragStartIndex].view;
    if (justStarted)
        view.hidden = YES;
    else
        view.animator.hidden = YES;
    return NSDragOperationMove;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)info {
    if (self.sf.stringValue.length != 0)
        return NSDragOperationNone;
    
    StartMenu *menu = self.menuContainer.content;
    NSUInteger newDragIndex = [self indexForWindowPoint:info.draggingLocation];
    [menu moveItemAtIndex:self.dragIndex toIndex:newDragIndex];
    self.dragIndex = newDragIndex;
    return NSDragOperationMove;
}

- (void)draggingExited:(id<NSDraggingInfo>)info {
    if (self.sf.stringValue.length != 0)
        return;
    
    StartMenu *menu = self.menuContainer.content;
    [menu moveItemAtIndex:self.dragIndex toIndex:self.dragStartIndex];
    self.dragIndex = NSNotFound;
    NSView *view = [self itemAtIndex:self.dragStartIndex].view;
    view.animator.hidden = NO;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)info {
    NSView *view = [self itemAtIndex:self.dragIndex].view;
    StartMenuItem *item = [self itemAtIndex:self.dragIndex].representedObject;
    // I have completely given up on trying to turn the view into an image.
    NSImage *dragImage = item.dragImage;
    NSRect startRect;
    startRect.origin = info.draggedImageLocation;
    startRect.size = dragImage.size;
    startRect = [self.window convertRectToScreen:startRect];
    NSRect endRect = [self.window convertRectToScreen:[self convertRect:view.frame toView:nil]];
    // I'm not entirely sure why this rect is 5 too high. But this works. OK?
    endRect.origin.y -= 5;
    
    self.dragAnimation = [[NSWindow alloc] initWithContentRect:startRect
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    NSImageView *content = [[NSImageView alloc] initWithFrame:[self.dragAnimation contentRectForFrameRect:self.dragAnimation.frame]];
    content.image = dragImage;
    self.dragAnimation.contentView = content;
    self.dragAnimation.level = self.window.level + 1;
    self.dragAnimation.backgroundColor = [NSColor clearColor];
    [self.dragAnimation orderFront:nil];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [self.dragAnimation.animator setFrame:endRect display:YES];
    } completionHandler:^{
        view.hidden = NO;
        [self.dragAnimation orderOut:nil];
    }];
    
    return YES;
}

- (void)draggingEnded:(id<NSDraggingInfo>)info {
    self.dragIndex = self.dragStartIndex = NSNotFound;
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return NO;
}

- (NSImage *)imageFromView:(NSView *)view {
    return [[NSImage alloc] initWithData:[view dataWithPDFInsideRect:view.bounds]];
}

- (NSUInteger)indexForWindowPoint:(NSPoint)point {
    StartMenu *menu = self.menuContainer.content;
    NSPoint myPoint = [self convertPoint:point fromView:nil];
    NSUInteger i;
    for (i = 0; i < menu.items.count; i++) {
        if (NSPointInRect(myPoint, [self frameForItemAtIndex:i])) {
            return i;
        }
    }
    return i - 1;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    NSCollectionViewItem *item = [super newItemForRepresentedObject:object];
    NSButton *button = item.view.subviews[0];
    NSAssert([button isKindOfClass:[NSButton class]], @"should be a button");
    [button.cell setRepresentedObject:object];
    return item;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
