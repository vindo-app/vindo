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

- (WorldStatus)statusOfWorldNamed:(NSString *)worldName {
    WorldsController *worlds = [WorldsController sharedController];
    
    World *world = [self worldForName:worldName];
    if (world == nil) {
        return WorldStatusNonexistent;
    }
    
    if (![worlds.selectedWorld isEqual:world]) {
        worlds.selectedObjects = @[world];
    }
    
    if (world.state == WineServerRunning) {
        return WorldStatusRunning;
    } else {
        return WorldStatusStarting;
    }
}

- (bycopy NSDictionary *)environmentForWorld:(NSString *)world {
    return [self worldForName:world].wineEnvironment;
}

- (NSString *)programForStartMenuItem:(NSString *)nativeIdentifier inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    if (world == nil)
        return nil;
    
    StartMenuItem *item = [self startMenuItemForNativeIdentifier:nativeIdentifier
                                                         inWorld:world];
    if (item == nil)
        return nil;
    
    return item.path;
}

- (NSString *)argumentsForStartMenuItem:(NSString *)nativeIdentifier inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    if (world == nil)
        return nil;
    
    StartMenuItem *item = [self startMenuItemForNativeIdentifier:nativeIdentifier
                                                         inWorld:world];
    if (item == nil)
        return nil;
    
    return item.args;
}

- (StartMenuItem *)startMenuItemForNativeIdentifier:(NSString *)nativeIdentifier inWorld:(World *)world {
    StartMenu *menu = [StartMenuController sharedInstance].menu;
    
    for (StartMenuItem *item in menu.items) {
        if ([item.nativeIdentifier isEqualToString:nativeIdentifier]) {
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
