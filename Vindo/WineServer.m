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
    NSAssert(!self.serverTask.running, @"attempt to start %@ which is already started", self);
    
    // make sure prefix directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager createDirectoryAtURL:self.url
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil]) {
        return;
    }
    
    NSTask *killServer = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
    [killServer launch];
    [killServer waitUntilExit];
    
    self.serverTask = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
    @weakify(self);
    self.serverTask.terminationHandler = ^(id _) {
        @strongify(self);
        [self start];
    };
    [self.serverTask launch];
}

- (void)stop {
    NSAssert(self.serverTask.running, @"attempt to stop %@ which is already stopped", self);
    
    // first end the session with wineboot
    NSTask *endSession = [self wineTaskWithProgram:@"wine"
                                         arguments:@[@"wineboot", @"--end-session", @"--shutdown"]];
    endSession.terminationHandler = ^(NSTask *_) {
        self.serverTask.terminationHandler = nil;
        NSTask *killServer = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [self.serverTask waitUntilExit];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WorldDidStopNotification object:self];
    };
    [endSession launch];
}

@end

NSString *const WorldDidStopNotification = @"WorldDidStopNotification";
