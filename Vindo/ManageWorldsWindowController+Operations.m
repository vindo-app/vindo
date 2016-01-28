//
//  ManageWorldsWindowController+Operations.m
//  Vindo
//
//  Created by Theodore Dubois on 1/25/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "ManageWorldsWindowController.h"
#import "World.h"
#import "NSObject+Notifications.h"
#import "StartMenu.h"
#import "StartMenuItem.h"
#import "StartMenuController.h"
#import "WorldsController.h"

@implementation ManageWorldsWindowController (Operations)

- (void)addWorldNamed:(NSString *)name {
    [self.statusWindow appear];
    World *world = [[World alloc] initWithName:name];
    
    [world onNext:WorldDidFinishSetupNotification
               do:^(id n) {
                   [self.arrayController addObject:world];
                   self.arrayController.selectedObjects = @[world];
                   [self.statusWindow disappear];
               }];
    [world setup];
}

- (void)removeWorlds:(NSArray *)worlds {
    [self.statusWindow appear];
    
    NSMutableArray *worldsToDelete = worlds.mutableCopy;
    
    for (World *world in worldsToDelete) {
        [world onNext:WorldDidStopNotification
                   do:^(id n) {
                       [[NSFileManager defaultManager] trashItemAtURL:world.url
                                                     resultingItemURL:nil
                                                                error:nil]; // move world to trash
                       [self.arrayController removeObject:world]; // remove object from worlds
                       // delete any other world-specific defaults keys
                       [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:[NSString stringWithFormat:@"startMenuItems.%@", world.name]];
                       [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:[NSString stringWithFormat:@"displayNames.%@", world.name]];
                       [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:[NSString stringWithFormat:@"subrank.%@", world.name]];
                       
                       [worldsToDelete removeObject:world];
                       if (worldsToDelete.count == 0) {
                           [self.statusWindow disappear];
                       }
                   }];
        [world stop];
    }
}

- (void)renameWorld:(World *)world toName:(NSString *)name {
    StartMenu *menu;
    if ([[WorldsController sharedController].selectedWorld isEqual:world])
        menu = [StartMenuController sharedInstance].menu;
    else
        menu = [[StartMenu alloc] initWithWorld:world];
    for (StartMenuItem *item in menu.items) {
        if (item.bundle.parenthesized) {
            [item.bundle remove];
        }
    }
    // use these kvos to tell worlds menu controller to refresh
    [[WorldsController sharedController] willChangeValueForKey:@"arrangedObjects"];
    world.displayName = name;
    [[WorldsController sharedController] didChangeValueForKey:@"arrangedObjects"];
    for (StartMenuItem *item in menu.items) {
        [item.bundle generate];
    }
}

- (void)duplicateThisWorld:(World *)world {
    [self.statusWindow appear];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *worldsDir = [[fm URLsForDirectory:NSApplicationSupportDirectory
                                       inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"Vindo/Worlds"];
        
        // find a good name for the new world
        NSString *newName = [world.displayName stringByAppendingString:@" copy"];
        NSString *nameWithN;
        NSUInteger n = 1;
        while (YES) {
            if (n <= 1)
                nameWithN = newName;
            else
                nameWithN = [NSString stringWithFormat:@"%@ %lu", newName, n];
            
            if ([fm fileExistsAtPath:[worldsDir URLByAppendingPathComponent:nameWithN].path])
                n++;
            else
                break;
        }
        NSURL *newURL = [worldsDir URLByAppendingPathComponent:nameWithN];
        if (![fm copyItemAtURL:world.url toURL:newURL error:nil]) {
            NSLog(@"fail fail fail");
            NSAssert(NO, @"Report this!");
        }
        
        World *newWorld = [[World alloc] initWithName:nameWithN];
        [self.arrayController addObject:newWorld];
        
        [self.statusWindow disappear];
    });
}

@end
