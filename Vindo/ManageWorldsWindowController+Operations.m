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
                       
                       [worldsToDelete removeObject:world];
                       if (worldsToDelete.count == 0) {
                           [self.statusWindow disappear];
                       }
                   }];
        [world stop];
    }
}

- (void)renameWorld:(World *)world toName:(NSString *)name {
    StartMenu *menu = [[StartMenu alloc] initWithWorld:world];
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

@end
