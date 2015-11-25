//
//  PopupController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "PopupController.h"

@implementation PopupController

- (void)awakeFromNib {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.highlightMode = YES;
    NSImage *statusBarImage = [NSImage imageNamed:@"statusbar"];
    statusBarImage.template = YES;
    self.statusItem.image = statusBarImage;
    
    self.statusItem.target = self;
    self.statusItem.action = @selector(togglePopover:);
    
    self.popover = [[RBLPopover alloc] initWithContentViewController:self.popupViewController];
    self.popover.behavior = RBLPopoverBehaviorTransient;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changePopupSize:)
                                                 name:@"SetPopupSize"
                                               object:nil];
}

- (void)togglePopover:(id)sender {
    if (self.popover.shown)
        [self hidePopover];
    else
        [self showPopover];
}

- (void)showPopover {
    [self.popover showRelativeToRect:self.statusItem.button.bounds
                              ofView:self.statusItem.button
                       preferredEdge:NSMaxYEdge];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)hidePopover {
    [self.popover performClose:self];
}

- (void)changePopupSize:(NSNotification *)notification {
    self.popover.contentSize = [notification.userInfo[@"size"] sizeValue];
    [self showPopover];
}

@end
