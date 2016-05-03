//
//  StartMenuDefaultsSync.m
//  Vindo
//
//  Created by Theodore Dubois on 1/9/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "StartMenuDefaultsSync.h"
#import "StartMenuController.h"
#import "StartMenuItem.h"
#import "NSUserDefaults+KeyPaths.h"

@interface StartMenuDefaultsSync ()

@property StartMenu *menu;

@end

@implementation StartMenuDefaultsSync

- (instancetype)init {
    if (self = [super init]) {
        StartMenuController *smc = [StartMenuController sharedInstance];
        [smc addObserver:self
              forKeyPath:@"menu"
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                 context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == [StartMenuController sharedInstance]) {
        [change[NSKeyValueChangeOldKey] removeObserver:self forKeyPath:@"items"];
        self.menu = change[NSKeyValueChangeNewKey];
        [change[NSKeyValueChangeNewKey] addObserver:self
                                         forKeyPath:@"items" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                            context:NULL];
        return;
    }
    
    World *world = self.menu.world;
    
    NSMutableArray *items = self.menu.items.mutableCopy;
    for (int i = 0; i < items.count; i++) {
        StartMenuItem *item = items[i];
        items[i] = item.itemPath;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:items forKeyPathArray:@[@"startMenuItems", world.worldId]];
}

@end
