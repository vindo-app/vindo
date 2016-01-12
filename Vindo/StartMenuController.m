//
//  StartMenuController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuController.h"
#import "WorldsController.h"
#import "StartMenuDefaultsSync.h"

@interface StartMenuController ()

@property StartMenu *menu;
@property StartMenuDefaultsSync *syncer;

@end

static StartMenuController *sharedInstance;

@implementation StartMenuController

- (instancetype)init {
    if (sharedInstance)
        return sharedInstance;
    
    if (self = [super init]) {
        WorldsController *worldsController = [WorldsController sharedController];
        [worldsController addObserver:self
                           forKeyPath:@"selectionIndex"
                              options:NSKeyValueObservingOptionInitial
                              context:NULL];
        sharedInstance = self;
        self.syncer = [StartMenuDefaultsSync new];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    WorldsController *worldsController = [WorldsController sharedController];

    // Deal with stupidities.
    if (worldsController.selectedWorld == nil) {
        NSLog(@"smc: not going to %@", worldsController.selectedWorld);
        return;
    }
    
    if (worldsController.selectedWorld != nil) {
        NSLog(@"smc: menu created from world %@", worldsController.selectedWorld);
        self.menu = [[StartMenu alloc] initWithWorld:worldsController.selectedWorld];
        // Set a breakpoint here to inspect the menu.
    } else {
        NSLog(@"smc: menu being set to nil");
        self.menu = nil;
    }
}

+ (StartMenuController *)sharedInstance {
    return [self new];
}

@end
