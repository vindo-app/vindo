//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSObject+Notifications.h"

@implementation World (WineServer);

- (void)start {
    if (self.state == WineServerRunning ||
        self.state == WineServerStarting) {
        return;
    }
    if (self.state == WineServerStopping) {
        [self onNext:WorldDidStopNotification
                  do:^(id n) {
                      [self actuallyStart];
                  }];
    } else {
        [self actuallyStart];
    }
}

- (void)actuallyStart {
    self.state = WineServerStarting;
    NSLog(@"%@ state is now starting", self);

    // make sure prefix directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager createDirectoryAtURL:self.url
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil]) {
        return;
    }

    self.serverTask = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
    [self.serverTask launch];

    // now that the server is launched, run wineboot to fake boot the system
    NSTask *wineboot = [self wineTaskWithProgram:@"wine" arguments:@[@"wineboot", @"--init"]];

    wineboot.terminationHandler = ^(NSTask *_) {
        self.state = WineServerRunning;
        NSLog(@"%@ state is now running", self);

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WorldDidStartNotification object:self];
    };

    [wineboot launch];
}

- (void)stop {
    if (self.state == WineServerStopped) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WorldDidStopNotification object:self];
        return;
    }
    if (self.state == WineServerStopping) {
        return;
    }
    if (self.state == WineServerStarting) {
        [self onNext:WorldDidStartNotification
                  do:^(id n) {
                      [self actuallyStop];
                  }];
    } else {
        [self actuallyStop];
    }
}

- (void)actuallyStop {
    self.state = WineServerStopping;
    NSLog(@"state is now stopping");
    // first end the session with wineboot
    NSTask *endSession = [self wineTaskWithProgram:@"wine"
                                         arguments:@[@"wineboot", @"--end-session", @"--shutdown"]];
    endSession.terminationHandler = ^(NSTask *_) {
        NSTask *killServer = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [self.serverTask waitUntilExit];

        self.state = WineServerStopped;
        [[NSNotificationCenter defaultCenter] postNotificationName:WorldDidStopNotification object:self];
        NSLog(@"state is now stopped");
    };
    [endSession launch];
}

- (BOOL)isRunning {
    return self.state == WineServerRunning;
}

@end

NSString *const WorldDidStartNotification = @"WorldDidStartNotification";
NSString *const WorldDidStopNotification = @"WorldDidStopNotification";
