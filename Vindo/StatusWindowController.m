//
//  ServerStatusWindowController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StatusWindowController.h"

@interface StatusWindowController ()

@property NSWindow *sheetWindow;

@property IBOutlet NSTextField *placeholder;
@property IBOutlet NSProgressIndicator *progress;

@property NSTimer *timer;

@end

@implementation StatusWindowController

- (instancetype)initWithMessage:(NSString *)message
                    sheetWindow:(NSWindow *)window
              startNotification:(NSString *)startNotification
               stopNotification:(NSString *)stopNotification
                         object:(id)object {
    if (self = [super initWithWindowNibName:@"Status"]) {
        _message = message;
        _sheetWindow = window;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(appear:)
                       name:startNotification
                     object:object];
        [center addObserver:self
                   selector:@selector(disappear:)
                       name:stopNotification
                     object:object];
    }
    return self;
}

- (void)appear:(NSNotification *)notification {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(actuallyAppear:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)actuallyAppear:(NSTimer *)timer {
    if (_sheetWindow == nil)
        [self showWindow:timer];
    else
        [NSApp beginSheet:self.window
           modalForWindow:_sheetWindow
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:NULL];
}

- (void)disappear:(NSNotification *)notification {
    [self.timer invalidate];
    self.timer = nil;
    if (_sheetWindow != nil)
        [NSApp endSheet:self.window];
    [self close];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.placeholder.stringValue = self.message;
    [self.progress startAnimation:self];
}

@end
