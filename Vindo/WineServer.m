//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServer.h"
#import "WinePrefix.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSObject+Notifications.h"

typedef enum {
    WineServerStopped,
    WineServerStarting,
    WineServerRunning,
    WineServerStopping
} WineServerState;

@interface WineServer ()

@property NSTask *serverTask;
@property WineServerState state;

@end

@implementation WineServer

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
        self.state = WineServerStopped;
    }
    return self;
}

- (void)start {
    if (self.state == WineServerRunning ||
        self.state == WineServerStarting) {
        return;
    }
    if (self.state == WineServerStopping) {
        [self onNext:WineServerDidStopNotification
                  do:^(id n) {
                      [self actuallyStart];
                  }];
    } else {
        [self actuallyStart];
    }
}

- (void)actuallyStart {
    self.state = WineServerStarting;

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
        self.state = WineServerRunning;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerDidStartNotification object:self];
    };

    [wineboot launch];
}

- (void)stop {
    if (self.state == WineServerStopped ||
        self.state == WineServerStopping) {
        return;
    }
    if (self.state == WineServerStarting) {
        [self onNext:WineServerDidStartNotification
                  do:^(id n) {
                      [self actuallyStart];
                  }];
    } else {
        [self actuallyStop];
    }
}

- (void)actuallyStop {
    self.state = WineServerStopping;
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
        self.state = WineServerStopped;
    };
    [endSession launch];
}

- (BOOL)isRunning {
    return self.state == WineServerRunning;
}

@end

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";