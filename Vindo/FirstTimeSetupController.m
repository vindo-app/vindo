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
#import "WorldsController.h"
#import "NSOperationQueue+DefaultQueue.h"

@interface FirstTimeSetupController ()

@property (getter=isHappening) BOOL happening;

@end

@implementation FirstTimeSetupController

- (id)init {
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(checkForFirstTimeSetup:)
                       name:NSApplicationDidFinishLaunchingNotification
                     object:nil];
    }
    return self;
}

- (void)checkForFirstTimeSetup:(NSNotification *)notification {
    WorldsController *worlds = [WorldsController sharedController];

    if ([worlds.arrangedObjects count] == 0) {
        [[NSOperationQueue defaultQueue] addOperationWithBlock:^{
            self.happening = YES;

            World *defaultWorld = [[World alloc] initWithName:@"Default World"];

            [worlds addObject:defaultWorld];
            worlds.selectedObjects = @[defaultWorld];

            [defaultWorld.prefix startServerAndWait];
            
            self.happening = NO;
        }];
    }
}

@end
