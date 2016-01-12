//
//  BootCycleController.m
//  Vindo
//
//  Created by Theodore Dubois on 6/23/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BootCycleController.h"
#import "WorldsController.h"

@interface BootCycleController ()

// The array controller is stupid. It will only tell me that a change occurred, not the old value. Or even the new value. Whenever the value changes, I'll store it here, so I can get the old value next time.
@property World *oldSelectedWorld;

@end

@implementation BootCycleController

- (id)init {
    if (self = [super init]) {
        [[WorldsController sharedController] addObserver:self
                                              forKeyPath:@"selectionIndex"
                                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                 context:NULL];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(stopOnQuit:)
                       name:NSApplicationWillTerminateNotification
                     object:NSApp];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    World *newSelectedWorld = [[WorldsController sharedController] selectedWorld];

    if ([self.oldSelectedWorld isEqualTo:newSelectedWorld])
        return;

    // Deal with the stupidities of the array controller.
    if (newSelectedWorld == nil) {
        NSLog(@"not going from %@ to %@", self.oldSelectedWorld, newSelectedWorld);
        return;
    }
    
    NSLog(@"    going from %@ to %@", self.oldSelectedWorld, newSelectedWorld);
    
    [self.oldSelectedWorld stop];
    [newSelectedWorld start];

    self.oldSelectedWorld = newSelectedWorld; // save for next time
}

- (void)stopOnQuit:(NSNotification *)notification {
    [[WorldsController sharedController].selectedWorld stop];
}

@end
