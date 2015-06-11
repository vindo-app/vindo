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

- (instancetype)initWithMessage:(NSString *)message
                    sheetWindow:(NSWindow *)window
                      operation:(NSOperation *)operation {
    if (self = [super initWithWindowNibName:@"Status"]) {
        _message = message;
        _sheetWindow = window;
        
        [operation addObserver:self
                    forKeyPath:@"isExecuting"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
        [operation addObserver:self
                    forKeyPath:@"isFinished"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"isExecuting"]) {
        if ([change[NSKeyValueChangeNewKey] boolValue] == YES) {
            [self appear:nil];
        }
    } else if ([keyPath isEqualToString:@"isFinished"]) {
        if ([change[NSKeyValueChangeNewKey] boolValue] == YES) {
            [self disappear:nil];
        }
    }
}

- (void)appear:(NSNotification *)notification {
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

- (void)disappear:(NSNotification *)notification {
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
