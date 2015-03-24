//
//  ServerStatusWindowController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StatusWindowController.h"

@interface StatusWindowController ()

@property IBOutlet NSTextField *placeholder;
@property IBOutlet NSProgressIndicator *progress;

@property NSTimer *timer;

@end

@implementation StatusWindowController

- (instancetype)initWithMessage:(NSString *)message
              startNotification:(NSString *)startNotification
               stopNotification:(NSString *)stopNotification
                         object:(id)object {
    if (self = [super initWithWindowNibName:@"ServerStatus"]) {
        _message = message;
        
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
    [self showWindow:timer];
}

- (void)disappear:(NSNotification *)notification {
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
