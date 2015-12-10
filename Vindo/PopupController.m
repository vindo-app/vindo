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

@interface PopupController ()

@property PopupViewController *pvc;
@property StatusBarView *statusBarView;
@property NSPopover *popover;
@property NSStatusItem *statusItem;

@property id globalMonitor;
@property id localMonitor;

@end

@implementation PopupController

- (void)awakeFromNib {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    NSImage *statusBarImage = [NSImage imageNamed:@"statusbar"];
    statusBarImage.template = YES;
    
    self.statusBarView = [[StatusBarView alloc] initWithImage:statusBarImage statusItem:self.statusItem];
    
    self.statusBarView.target = self;
    
    self.statusBarView.action = @selector(togglePopover:);
    
    self.statusItem.view = self.statusBarView;
    
    self.pvc = [PopupViewController new];
    
    self.popover = [NSPopover new];
    self.popover.contentViewController = self.pvc;
    self.popover.behavior = NSPopoverBehaviorTransient;
    
    [self.popover on:NSPopoverWillShowNotification
                  do:^(id n) {
                      self.statusBarView.highlighted = YES;
                  }];
    [self.popover on:NSPopoverWillCloseNotification
                  do:^(id n) {
                      self.statusBarView.highlighted = NO;
                  }];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reshowPopup:)
                                                 name:@"ReshowPopup"
                                               object:nil];
    
    [self.popover on:NSPopoverWillShowNotification
            doAction:@selector(createEventMonitors:)
            onTarget:self];
    
    [NSApp on:NSApplicationDidResignActiveNotification
           do:^(id n) {
               [self hidePopover];
           }];
}

- (void)createEventMonitors:(NSNotification *)notification {
    // Heavily inspired by RBLPopover.
    [self removeEventMonitors];
    
    __weak id weakSelf = self;
    void (^monitor)(NSEvent *event) = ^(NSEvent *event) {
        PopupController *strongSelf = weakSelf;
        BOOL mouseInPopoverWindow = ([NSWindow windowNumberAtPoint:NSEvent.mouseLocation belowWindowWithWindowNumber:0] == strongSelf.pvc.view.window.windowNumber);
        BOOL inParentWindow = ([NSWindow windowNumberAtPoint:NSEvent.mouseLocation belowWindowWithWindowNumber:0] == strongSelf.statusBarView.window.windowNumber);
        
        if (!mouseInPopoverWindow && !inParentWindow)
            [strongSelf hidePopover];
    };
    self.globalMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSRightMouseDownMask
                                                                handler:monitor];
    self.localMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSRightMouseDownMask
                                                              handler:^(NSEvent *e) {
                                                                  monitor(e);
                                                                  return e;
                                                              }];
}

- (void)removeEventMonitors {
    if (self.globalMonitor) {
        [NSEvent removeMonitor:self.globalMonitor];
        self.globalMonitor = nil;
    }
    if (self.localMonitor) {
        [NSEvent removeMonitor:self.localMonitor];
        self.localMonitor = nil;
    }
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
