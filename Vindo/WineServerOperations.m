//
//  WineServerOperations.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServerOperations.h"

// secret info about WinePrefix
@interface World ()

@property WineServerState state;

- (NSTask *)taskWithWindowsProgram:(NSString *)program arguments:(NSArray *)arguments;
- (NSTask *)taskWithProgram:(NSString *)program arguments:(NSArray *)arguments;

@property NSTask *server;

@end

@implementation StartWineServerOperation

- (instancetype)initWithWorld:(World *)prefix {
    if (self = [super init]) {
        _world = prefix;
    }
    return self;
}

- (void)main {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStartNotification object:self.world];
        
        if (self.isCancelled)
            return;
        
        // make sure prefix directory exists
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        if (![manager createDirectoryAtURL:_world.path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error]) {
            [NSApp presentError:error];
            return;
        }
        
        NSTask *server = [_world taskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
        
        if (self.isCancelled)
            return;

        [server launch];
        
        if (self.isCancelled) {
            [server terminate];
            [server waitUntilExit];
            return;
        }
        
        _world.server = server;
        
        // now that the server is launched, run wineboot to fake boot the system
        NSTask *wineboot = [_world taskWithWindowsProgram:@"wineboot" arguments:@[]];
        [wineboot launch];
        [wineboot waitUntilExit];

        [center postNotificationName:WineServerDidStartNotification object:self.world];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

- (BOOL)isReady {
    switch (_world.state) {
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
    return [NSSet setWithObject:@"world.state"];
}

@end

@implementation StopWineServerOperation

- (instancetype)initWithWorld:(World *)world {
    if (self = [super init]) {
        _world = world;
    }
    return self;
}

- (void)main {
    @try {
        // first end the session with wineboot
        NSTask *endSession = [_world taskWithWindowsProgram:@"wineboot" arguments:@[@"--end-session --shutdown"]];
        [endSession launch];
        [endSession waitUntilExit];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center postNotificationName:WineServerWillStopNotification object:self.world];
        NSTask *killServer = [_world taskWithProgram:@"wineserver" arguments:@[@"--kill"]];
        [killServer launch];
        [_world.server waitUntilExit];
        
        [center postNotificationName:WineServerDidStopNotification
                              object:self.world];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end


@implementation RunOperation

- (instancetype)initWithWorld:(World *)prefix program:(NSString *)program arguments:(NSArray *)arguments {
    if (self = [super init]) {
        _world = prefix;
        _program = program;
        _arguments = arguments;
    }
    return self;
}

- (void)main {
    @try {
        NSTask *program = [_world taskWithWindowsProgram:_program arguments:_arguments];
        [program launch];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end