//
//  ServerStatusWindowController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ServerStatusWindowController.h"

@interface ServerStatusWindowController ()

@property IBOutlet NSTextField *placeholder;
@property IBOutlet NSProgressIndicator *progress;

@property NSTimer *timer;

@end

@implementation ServerStatusWindowController

- (instancetype)initWithMessage:(NSString *)message {
    if (self = [super initWithWindowNibName:@"ServerStatus"]) {
        _message = message;
    }
    return self;
}

- (void)appear {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(actuallyAppear:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)actuallyAppear:(NSTimer *)timer {
    [self showWindow:timer];
}

- (void)disappear {
    [self.timer invalidate];
    self.timer = nil;
    [self close];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.placeholder.stringValue = self.message;
    [self.progress startAnimation:self];
}

@end
