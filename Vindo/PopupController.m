//
//  PopupController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "PopupController.h"
#import "StatusBarView.h"
#import "PopupViewController.h"
#import "NSObject+Notifications.h"

@implementation PopupController

- (void)awakeFromNib {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    NSImage *statusBarImage = [NSImage imageNamed:@"statusbar"];
    statusBarImage.template = YES;
    
    StatusBarView *statusBarView = [[StatusBarView alloc] initWithImage:statusBarImage statusItem:self.statusItem];
    
    statusBarView.target = self;
    statusBarView.action = @selector(togglePopover:);
    
    self.statusItem.view = statusBarView;
    
    self.pvc = [PopupViewController new];
    
    self.popover = [NSPopover new];
    self.popover.contentViewController = self.pvc;
    self.popover.behavior = NSPopoverBehaviorTransient;
    
    [self.popover on:NSPopoverWillShowNotification
                  do:^(id n) {
                      statusBarView.highlighted = YES;
                  }];
    [self.popover on:NSPopoverWillCloseNotification
                  do:^(id n) {
                      statusBarView.highlighted = NO;
                  }];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reshowPopup:)
                                                 name:@"ReshowPopup"
                                               object:nil];
}

- (void)togglePopover:(id)sender {
    if (self.popover.shown)
        [self hidePopover];
    else
        [self showPopover];
}

- (void)showPopover {
    [self.popover showRelativeToRect:self.statusItem.view.bounds
                              ofView:self.statusItem.view
                       preferredEdge:NSMaxYEdge];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)hidePopover {
    [self.popover performClose:self];
}

- (void)reshowPopup:(NSNotification *)notification {
    self.popover.contentSize = self.pvc.view.bounds.size;
}

@end
