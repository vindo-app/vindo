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
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
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

    StartMenuItem *changedItem = change[NSKeyValueChangeNewKey][0];
    switch ([change[NSKeyValueChangeKindKey] intValue]) {
        case NSKeyValueChangeInsertion:
            [self generateBundleForItem:changedItem];
            break;
        case NSKeyValueChangeRemoval:
            [self removeBundleForItem:changedItem];
            break;
    }
}

- (void)generateBundleForItem:(StartMenuItem *)addedItem {
    NSLog(@"generating bundle %@", addedItem);
}

- (void)removeBundleForItem:(StartMenuItem *)removedItem {
    NSLog(@"removing bundle %@", removedItem);
}

@end
