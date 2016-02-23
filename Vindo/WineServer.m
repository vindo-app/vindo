//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "NSObject+Notifications.h"

@implementation World (WineServer);

- (void)start {
    if (self.running)
        return;
    
    // make sure prefix directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager createDirectoryAtURL:self.url
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil]) {
        return;
    }
    
    self.serverTask = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--foreground"]];
    [self.serverTask launch];
}

- (void)stop {
    // first end the session with wineboot
    NSTask *endSession = [self wineTaskWithProgram:@"wine"
                                         arguments:@[@"wineboot", @"--end-session", @"--shutdown"]];
    endSession.terminationHandler = ^(NSTask *_) {
        NSTask *killServer = [self wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
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
