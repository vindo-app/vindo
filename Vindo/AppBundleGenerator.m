//
//  AppBundleGenerator.m
//  Vindo
//
//  Created by Theodore Dubois on 12/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "AppBundleGenerator.h"
#import "StartMenu.h"
#import "StartMenuController.h"
#import "StartMenuItem.h"

@interface AppBundleGenerator ()

@property StartMenu *menu;

@end

@implementation AppBundleGenerator

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
        [change[NSKeyValueChangeNewKey] addObserver:self
                                         forKeyPath:@"items" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                            context:NULL];
        return;
    }

    NSArray *old = change[NSKeyValueChangeOldKey];
    NSArray *new = change[NSKeyValueChangeNewKey];

    NSMutableArray *addedItems = [new mutableCopy];
    [addedItems removeObjectsInArray:old];
    for (StartMenuItem *addedItem in addedItems) {
        [self generateBundleForItem:addedItem];
    }

    NSMutableArray *removedItems = [old mutableCopy];
    [removedItems removeObjectsInArray:new];
    for (StartMenuItem *removedItem in removedItems) {
        [self removeBundleForItem:removedItem];
    }
}

- (void)generateBundleForItem:(StartMenuItem *)addedItem {
    
}

- (void)removeBundleForItem:(StartMenuItem *)removedItem {
    
}

@end
