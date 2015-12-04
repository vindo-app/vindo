//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServer.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface WineServer ()

@property NSTask *serverTask;
@property BOOL running;
@property BOOL pending;

@end

// the operations that start and stop a wine server
#include "StopWineServerOperation.inl"

@implementation WineServer

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)start {
    if ((self.running && !self.pending) ||
        (!self.running && self.pending)) {
        return;
    }
    if (self.running && self.pending) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAfterStop:)
                                                     name:WineServerDidStopNotification
                                                   object:self];
    }

    [self actuallyStart];
}

- (void)startAfterStop:(NSNotification *)notification {
    [self actuallyStart];
}

- (void)actuallyStart {
    self.pending = YES;

    // make sure prefix directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager createDirectoryAtURL:_prefix.prefixURL
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil]) {
        return;
    }

    self.serverTask = [_prefix wineTaskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
    [self.serverTask launch];

    // now that the server is launched, run wineboot to fake boot the system
    NSTask *wineboot = [_prefix wineTaskWithProgram:@"wine" arguments:@[@"wineboot"]];

    wineboot.terminationHandler = ^(NSTask *_) {
        self.running = YES;
        self.pending = NO;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerDidStartNotification object:self];
    };

    [wineboot launch];
}

- (void)stop {
    if ((!self.running && !self.pending) ||
        (self.running && self.pending)) {
        return;
    }
    if (!self.running && self.pending) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAfterStart:)
                                                     name:WineServerDidStartNotification
                                                   object:self];
    }

    [self actuallyStop];
}

- (void)stopAfterStart:(NSNotification *)notification {
    [self actuallyStop];
}

- (void)actuallyStop {
    self.running = NO;
    self.pending = YES;
    // first end the session with wineboot
    NSTask *endSession = [_prefix wineTaskWithProgram:@"wine"
                                            arguments:@[@"wineboot", @"--end-session", @"--shutdown"]];
    endSession.terminationHandler = ^(NSTask *_) {
        NSTask *killServer = [_prefix wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [self.serverTask waitUntilExit];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerDidStopNotification
                              object:self.prefix.server];
        self.running = NO;
    };
    [endSession launch];

    [center postNotificationName:WineServerDidStopNotification
                          object:self.prefix.server];

    self.prefix.server.running = NO;
    self.prefix.server.pendingOp = nil;
}

@end

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";