//
//  WineServerOperations.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServerOperations.h"

// secret info about WinePrefix
@interface WinePrefix ()

@property WineServerState state;

- (NSTask *)taskWithWindowsProgram:(NSString *)program arguments:(NSArray *)arguments;
- (NSTask *)taskWithProgram:(NSString *)program arguments:(NSArray *)arguments;

@property NSTask *server;

@end

@implementation StartWineServerOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)main {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStartNotification object:self.prefix];
        
        if (self.isCancelled)
            return;
        
        // make sure prefix directory exists
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        if (![manager createDirectoryAtURL:_prefix.path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error]) {
            [NSApp presentError:error];
            return;
        }
        
        NSTask *server = [_prefix taskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
        
        if (self.isCancelled)
            return;

        [server launch];
        
        if (self.isCancelled) {
            [server terminate];
            [server waitUntilExit];
            return;
        }
        
        _prefix.server = server;
        
        // now that the server is launched, run wineboot to fake boot the system
        NSTask *wineboot = [_prefix taskWithWindowsProgram:@"wineboot" arguments:@[]];
        [wineboot launch];
        [wineboot waitUntilExit];

        [center postNotificationName:WineServerDidStartNotification object:self.prefix];
    }
    @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

- (BOOL)isReady {
    switch (_prefix.state) {
        case WineServerStopped:
            return YES;
        case WineServerStopping:
            return NO;
        case WineServerStarting:
        case WineServerRunning:
            [self cancel];
            return NO;
    }
}

+ (NSSet *)keyPathsForValuesAffectingIsReady {
    return [NSSet setWithObject:@"prefix.state"];
}

@end

@implementation StopWineServerOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)main {
    @try {
        // first end the session with wineboot
        NSTask *endSession = [_prefix taskWithWindowsProgram:@"wineboot" arguments:@[@"--end-session --shutdown"]];
        [endSession launch];
        [endSession waitUntilExit];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center postNotificationName:WineServerWillStopNotification object:self.prefix];
        NSTask *killServer = [_prefix taskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [_prefix.server waitUntilExit];
        
        [center postNotificationName:WineServerDidStopNotification
                              object:self.prefix];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end


@implementation RunOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix program:(NSString *)program arguments:(NSArray *)arguments {
    if (self = [super init]) {
        _prefix = prefix;
        _program = program;
        _arguments = arguments;
    }
    return self;
}

- (void)main {
    @try {
        NSTask *program = [_prefix taskWithWindowsProgram:_program arguments:_arguments];
        [program launch];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end