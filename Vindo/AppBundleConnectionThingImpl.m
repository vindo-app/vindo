//
//  AppBundleConnectionThingImpl.m
//  Vindo
//
//  Created by Theodore Dubois on 1/6/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "AppBundleConnectionThingImpl.h"
#import "WorldsController.h"
#import "World.h"
#import "StartMenuController.h"
#import "StartMenuItem.h"

@implementation AppBundleConnectionThingImpl

- (bycopy NSURL *)usrURL {
    return [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"usr"];
}

- (BOOL)activateWorldNamed:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    [world start];
    return world != nil;
}

- (bycopy NSDictionary *)environmentForWorld:(NSString *)world {
    return [self worldForName:world].wineEnvironment;
}

- (NSString *)programForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    if (world == nil)
        return nil;
    
    StartMenuItem *item = [self startMenuItemForItemPath:itemPath
                                                 inWorld:world];
    if (item == nil)
        return nil;
    
    return item.path;
}

- (NSString *)argumentsForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    if (world == nil)
        return nil;
    
    StartMenuItem *item = [self startMenuItemForItemPath:itemPath
                                                 inWorld:world];
    if (item == nil)
        return nil;
    
    return item.args;
}

- (StartMenuItem *)startMenuItemForItemPath:(NSString *)itemPath inWorld:(World *)world {
    StartMenu *menu = [StartMenuController sharedInstance].menu;
    
    for (StartMenuItem *item in menu.items) {
        if ([item.itemPath isEqualToString:itemPath]) {
            return item;
        }
    }
    return nil;
}

- (World *)worldForName:(NSString *)worldName {
    WorldsController *worlds = [WorldsController sharedController];
    
    for (World *world in worlds.arrangedObjects) {
        if ([world.name isEqualToString:worldName]) {
            return world;
        }
    }
    return nil;
}

@end
