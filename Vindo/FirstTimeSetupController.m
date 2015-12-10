//
//  FirstTimeSetupController.m
//  Vindo
//
//  Created by Theodore Dubois on 9/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "FirstTimeSetupController.h"
#import "World.h"
#import "WinePrefix.h"
#import "WineServer.h"
#import "WorldsController.h"
#import "NSObject+Notifications.h"

@interface FirstTimeSetupController ()

@property (getter=isHappening) BOOL happening;

@end

static FirstTimeSetupController *sharedInstance;

@implementation FirstTimeSetupController

- (id)init {
    if (sharedInstance)
        return sharedInstance;
    
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(checkForFirstTimeSetup:)
                       name:NSApplicationDidFinishLaunchingNotification
                     object:nil];
    }
    sharedInstance = self;
    return self;
}

- (void)checkForFirstTimeSetup:(NSNotification *)notification {
    WorldsController *worlds = [WorldsController sharedController];
    
    if ([worlds.arrangedObjects count] == 0) {
        self.happening = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:FirstTimeSetupDidStartNotification object:self];
        
        World *defaultWorld = [[World alloc] initWithName:@"Default World"];
        
        [worlds addObject:defaultWorld];
        worlds.selectedObjects = @[defaultWorld];
        
        [defaultWorld.prefix startServer];
        
        [defaultWorld.prefix.server onNext:WineServerDidStartNotification
                                        do:^(id n) {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:FirstTimeSetupDidCompleteNotification object:self];
                                            self.happening = NO;
                                        }];
    }
}

+ (FirstTimeSetupController *)sharedInstance {
    return [self new];
}

@end

NSString *const FirstTimeSetupDidStartNotification = @"FirstTimeSetupDidStartNotification";
NSString *const FirstTimeSetupDidCompleteNotification = @"FirstTimeSetupDidStartNotification";