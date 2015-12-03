//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServer.h"
#import "NSOperationQueue+DefaultQueue.h"

@interface WineServer ()

@property NSTask *serverTask;
@property BOOL running;
@property NSOperation *pendingOp;

@end

// the operations that start and stop a wine server
#include "StartWineServerOperation.inl"
#include "StopWineServerOperation.inl"

@implementation WineServer

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)start {
    // Do this cleanup, because we can't trust the ops to do it themselves.
    if (self.pendingOp.isFinished)
        self.pendingOp = nil;

    // This is the only way to correctly implement the twisted logic. Don't change it.
    if (self.pendingOp) {
        if ([self.pendingOp isKindOfClass:[StartWineServerOperation class]]) {
            return;
        }
    } else if (self.running) {
        return;
    }
    
    NSOperation *startOp = [[StartWineServerOperation alloc] initWithWinePrefix:self.prefix];;
    if (self.pendingOp != nil) {
        [self.pendingOp cancel];
        [startOp addDependency:self.pendingOp];
    }
    self.pendingOp = startOp;
    [[NSOperationQueue defaultQueue] addOperation:startOp];
}

- (void)startAndWait {
    [self start];
    [self.pendingOp waitUntilFinished];
}

- (void)stop {
    // Do this cleanup, because we can't trust the ops to do it themselves.
    if (self.pendingOp.isFinished)
        self.pendingOp = nil;
    
    // This is the only way to correctly implement the twisted logic. Don't change it.
    if (self.pendingOp) {
        if ([self.pendingOp isKindOfClass:[StopWineServerOperation class]]) {
            return;
        }
    } else if (!self.running) {
        return;
    }
    
    NSOperation *stopOp = [[StopWineServerOperation alloc] initWithWinePrefix:self.prefix];
    if (self.pendingOp != nil) {
        [self.pendingOp cancel];
        [stopOp addDependency:self.pendingOp];
    }
    _pendingOp = stopOp;
    [[NSOperationQueue defaultQueue] addOperation:stopOp];
}

- (void)stopAndWait {
    [self stop];
    [self.pendingOp waitUntilFinished];
}

@end

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";