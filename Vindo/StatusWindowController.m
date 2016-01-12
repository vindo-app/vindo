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
                    sheetWindow:(NSWindow *)window {
    if (self = [super initWithWindowNibName:@"Status"]) {
        _message = message;
        _sheetWindow = window;
    }
    return self;
}

- (void)appear {
    // Since this might not be called from the main thread, we have to
    // add the timer to the main run loop instead of the current thread's run loop.
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(actuallyAppear:)
                                       userInfo:nil
                                        repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
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

- (void)disappear {
    [self performSelectorOnMainThread:@selector(actuallyDisappear) withObject:nil waitUntilDone:NO];
}

- (void)actuallyDisappear {
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
