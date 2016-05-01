//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "NSObject+Notifications.h"
#import <libextobjc/extobjc.h>

@implementation World (WineServer)

- (void)start {
    NSLog(@"we might start");
    if (self.running)
        return;
    
    NSLog(@"we will start");

    // make sure prefix directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager createDirectoryAtURL:self.url
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil]) {
        return;
    }
    
    self.serverTask = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
    @weakify(self);
    self.serverTask.terminationHandler = ^(id _) {
        @strongify(self);
        [self didChangeValueForKey:@"running"];
    };
    [self willChangeValueForKey:@"running"];
    [self.serverTask launch];
    [self didChangeValueForKey:@"running"];
}

- (void)stop {
    // first end the session with wineboot
    NSTask *endSession = [self wineTaskWithProgram:@"wine"
                                         arguments:@[@"wineboot", @"--end-session", @"--shutdown"]];
    endSession.terminationHandler = ^(NSTask *_) {
        NSTask *killServer = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [self willChangeValueForKey:@"running"];
        [self.serverTask waitUntilExit];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WorldDidStopNotification object:self];
    };
    [endSession launch];
}

- (BOOL)isRunning {
    return self.serverTask.running;
}

@end

NSString *const WorldDidStopNotification = @"WorldDidStopNotification";
