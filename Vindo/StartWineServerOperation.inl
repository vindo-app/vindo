//
//  StartWineServerOperation.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WinePrefix.h"

@interface StartWineServerOperation : NSOperation

- (instancetype)initWithWinePrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@end

@implementation StartWineServerOperation

- (instancetype)initWithWinePrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)main {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStartNotification object:self.prefix.server];
        
        if (self.isCancelled)
            return;
        
        // make sure prefix directory exists
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        if (![manager createDirectoryAtURL:_prefix.prefixURL
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error]) {
            [NSApp presentError:error];
            return;
        }
        
        NSTask *server = [_prefix wineTaskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
        
        if (self.isCancelled)
            return;
        
        [server launch];
        
        if (self.isCancelled) {
            [server terminate];
            [server waitUntilExit];
            return;
        }
        
        _prefix.server.serverTask = server;
        
        // now that the server is launched, run wineboot to fake boot the system
        NSTask *wineboot = [_prefix wineTaskWithProgram:@"wine" arguments:@[@"wineboot"]];
        [wineboot launch];
        [wineboot waitUntilExit];
        
        [center postNotificationName:WineServerDidStartNotification object:self.prefix.server];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end
