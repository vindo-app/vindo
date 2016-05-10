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
#import "NSUserDefaults+KeyPaths.h"
#import "StartMenu.h"
#import "StartMenuItem.h"
#import "StartMenuController.h"
#import "WorldsController.h"

@implementation ManageWorldsWindowController (Operations)

- (void)addWorldNamed:(NSString *)name {
    if ([self worldExistsNamed:name]) {
        [self performSelector:@selector(alertWorldExists:) withObject:name afterDelay:0];
        return;
    }
    
    [self.statusWindow appear];
    World *world = [[World alloc] initWithName:name];
    [world start];
    
    [world onNext:WorldDidFinishSetupNotification
               do:^(id n) {
                   [self.arrayController addObject:world];
                   self.arrayController.selectedObjects = @[world];
                   [self.statusWindow disappear];
               }];
    [world setup];
}

- (void)removeThisWorld:(World *)world {
    [self.statusWindow appear];
    
    [world onNext:WorldDidStopNotification
               do:^(id n) {
                   NSFileManager *fm = [NSFileManager defaultManager];
                   StartMenu *menu = [[StartMenu alloc] initWithWorld:world];
                   for (StartMenuItem *item in menu.items) {
                       [item.bundle remove];
                   }
                   
                   NSURL *thingy = [[[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0]
                                     URLByAppendingPathComponent:@"Vindo"]
                                    URLByAppendingPathComponent:world.name];
                   [fm moveItemAtURL:world.url toURL:thingy error:nil];
                   [fm trashItemAtURL:thingy resultingItemURL:nil error:nil]; // move world to trash
                   
                   [self.arrayController removeObject:world]; // remove object from worlds
                   // delete any app bundles
                   // delete any other world-specific defaults keys
                   [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPathArray:@[@"startMenuItems", world.worldId]];
                   [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPathArray:@[@"displayNames", world.worldId]];
                   
                   [self.statusWindow disappear];
               }];
    [world stop];
}

- (void)renameWorld:(World *)world toName:(NSString *)name {
    if ([self worldExistsNamed:name]) {
        [self performSelector:@selector(alertWorldExists:) withObject:name afterDelay:0];
        return;
    }
    
    StartMenu *menu;
    if ([[WorldsController sharedController].selectedWorld isEqual:world])
        menu = [StartMenuController sharedInstance].menu;
    else
        menu = [[StartMenu alloc] initWithWorld:world];
    for (StartMenuItem *item in menu.items) {
        [item.bundle remove];
    }
    
    // use these kvos to tell worlds menu controller to refresh
    [[WorldsController sharedController] willChangeValueForKey:@"arrangedObjects"];
    world.name = name;
    [[WorldsController sharedController] didChangeValueForKey:@"arrangedObjects"];
    
    for (StartMenuItem *item in menu.items) {
        [item.bundle generate];
    }
}

- (void)duplicateThisWorld:(World *)world {
    [self.statusWindow appear];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // find a good name for the new world
        NSString *newName = [self addNumberAfterName:[world.name stringByAppendingString:@" copy"]];
        World *newWorld = [[World alloc] initWithName:newName];
        NSError *error;
        if (![fm copyItemAtURL:world.url toURL:newWorld.url error:&error]) {
            NSLog(@"%@", error);
            [self.statusWindow disappear];
            [self.window performSelectorOnMainThread:@selector(presentError:) withObject:error waitUntilDone:NO];
            return;
        }
        
        [newWorld start];
        [self.arrayController performSelectorOnMainThread:@selector(addObject:) withObject:newWorld waitUntilDone:NO];
        
        [self.statusWindow disappear];
    });
}

- (void)importWorldAt:(NSURL *)worldURL {
    [self.statusWindow appear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *worldName = [self addNumberAfterName:worldURL.lastPathComponent];
        World *world = [[World alloc] initWithName:worldName];
        NSError *error;
        if (![fm copyItemAtURL:worldURL toURL:world.url error:&error]) {
            NSLog(@"%@", error);
            [self.statusWindow disappear];
            [self.window performSelectorOnMainThread:@selector(presentError:) withObject:error waitUntilDone:NO];
            return;
        }
        
        [world start];
        [self.arrayController performSelectorOnMainThread:@selector(addObject:) withObject:world waitUntilDone:NO];
        [self.statusWindow disappear];
    });
}

- (void)exportWorld:(World *)world to:(NSURL *)destination {
    [self.statusWindow appear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        if (![fm copyItemAtURL:world.url toURL:destination error:&error]) {
            NSLog(@"%@", error);
            [self.statusWindow disappear];
            [self.window performSelectorOnMainThread:@selector(presentError:) withObject:error waitUntilDone:NO];
            return;
        }
        
        [self.statusWindow disappear];
    });
}

- (NSString *)addNumberAfterName:(NSString *)name {
    NSString *nameWithNumber = name;
    for (int i = 2; [self worldExistsNamed:nameWithNumber]; i++)
        nameWithNumber = [name stringByAppendingFormat:@" %i", i];
    return nameWithNumber;
}

- (BOOL)worldExistsNamed:(NSString *)name {
    WorldsController *wc = [WorldsController sharedController];
    for (World *world in wc.arrangedObjects) {
        if ([world.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

- (void)alertWorldExists:(NSString *)name {
    NSAlert *alert = [NSAlert new];
    alert.messageText = [NSString stringWithFormat:@"There's alredy a world named \"%@\".", name];
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

@end
