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
@property NSURL *appBundleFolder;
@property NSURL *bundleAliasFolder;
@property NSURL *windowsProgramBundle;

@end

static NSFileManager *fm;

@implementation AppBundleGenerator

- (instancetype)init {
    if (self = [super init]) {
        StartMenuController *smc = [StartMenuController sharedInstance];
        [smc addObserver:self
              forKeyPath:@"menu"
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                 context:NULL];
        
        self.appBundleFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory
                                                                       inDomains:NSUserDomainMask][0]
                                URLByAppendingPathComponent:@"Vindo"];

        
        self.windowsProgramBundle = [[NSBundle mainBundle] URLForResource:@"Windows Program"
                                                            withExtension:@"app"];
        
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
        if (self.menu && self.menu != [NSNull null])
            self.bundleAliasFolder = [self.menu.world.url URLByAppendingPathComponent:@"bundles"];
        return;
    }
    
    if ([change[NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting) {
        
    } else {
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
}

- (void)generateBundleForItem:(StartMenuItem *)addedItem {
    if ([self bundleExistsForItem:addedItem])
        return;
    
    NSError *error;
    
    if (![fm createDirectoryAtURL:self.appBundleFolder
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error]) {
        [NSApp presentError:error];
        return;
    }
    
    if (![fm copyItemAtURL:self.windowsProgramBundle
                     toURL:[self bundleURLForItem:addedItem]
                     error:&error]) {
        [NSApp presentError:error];
        return;
    }
}

- (void)removeBundleForItem:(StartMenuItem *)removedItem {
    if (![self bundleExistsForItem:removedItem])
        return;
    
    NSError *error;
    
    if (![fm removeItemAtURL:[self bundleURLForItem:removedItem]
                       error:&error]) {
        [NSApp presentError:error];
        return;
    }
}

- (BOOL)bundleExistsForItem:(StartMenuItem *)item {
    return [fm fileExistsAtPath:[self bookmarkURLForItem:item].path];
}

- (NSURL *)bookmarkURLForItem:(StartMenuItem *)item {
    return [self.appBundleFolder URLByAppendingPathComponent:item.nativeIdentifier];
}

- (NSURL *)bundleURLForItem:(StartMenuItem *)item {
    return [[self.appBundleFolder URLByAppendingPathComponent:item.name] URLByAppendingPathExtension:@"app"];
}

+ (void)initialize {
    fm = [NSFileManager defaultManager];
}

@end
