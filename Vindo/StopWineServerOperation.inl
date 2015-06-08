//
//  StopWineServerOperation.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinePrefix.h"
#import "WineServer.h"

@interface StopWineServerOperation : NSOperation

- (instancetype)initWithWinePrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@end

@implementation StopWineServerOperation

- (instancetype)initWithWinePrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)main {
    @try {
        // first end the session with wineboot
        NSTask *endSession = [_prefix wineTaskWithProgram:@"wine"
                                                arguments:@[@"wineboot", @"--end-session", @"--shutdown"]];
        [endSession launch];
        [endSession waitUntilExit];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStopNotification
                              object:self.prefix.server];
        
        NSTask *killServer = [_prefix wineTaskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [_prefix.server.serverTask waitUntilExit];
        
        [center postNotificationName:WineServerDidStopNotification
                              object:self.prefix.server];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end
