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
@property FiletypeDatabase *filetypes;
@property StartMenuDefaultsSync *syncer;

@end

static StartMenuController *sharedInstance;

@implementation StartMenuController

- (instancetype)init {
    if (sharedInstance)
        return sharedInstance;
    
    if (self = [super init]) {
        sharedInstance = self;
        WorldsController *worldsController = [WorldsController sharedController];
        [worldsController addObserver:self
                           forKeyPath:@"selectionIndex"
                              options:NSKeyValueObservingOptionInitial
                              context:NULL];
        self.syncer = [StartMenuDefaultsSync new];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    WorldsController *worldsController = [WorldsController sharedController];
    
    // Deal with stupidities.
    if (worldsController.selectedWorld == nil) {
        return;
    }
    
    self.menu = [[StartMenu alloc] initWithWorld:worldsController.selectedWorld];
    self.filetypes = [[FiletypeDatabase alloc] initWithWorld:worldsController.selectedWorld];
}

+ (StartMenuController *)sharedInstance {
    return [self new];
}

@end
