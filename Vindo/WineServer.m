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
    if (!self.running) {
        [[NSOperationQueue defaultQueue] addOperation:
         [[StartWineServerOperation alloc] initWithWinePrefix:self.prefix]];
    }
}

- (void)startAndWait {
    if (!self.running) {
        NSOperation *startOp = [[StartWineServerOperation alloc] initWithWinePrefix:self.prefix];
        [[NSOperationQueue defaultQueue] addOperation:startOp];
        [startOp waitUntilFinished];
    }
}

- (void)stop {
    if (self.running) {
        [[NSOperationQueue defaultQueue] addOperation:
         [[StopWineServerOperation alloc] initWithWinePrefix:self.prefix]];
    }
}

- (void)stopAndWait {
    if (self.running) {
        NSOperation *stopOp = [[StopWineServerOperation alloc] initWithWinePrefix:self.prefix];
        [[NSOperationQueue defaultQueue] addOperation:stopOp];
        [stopOp waitUntilFinished];
    }
}

@end

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";