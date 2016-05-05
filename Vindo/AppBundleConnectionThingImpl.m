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
#import "Filetype.h"
#import "FiletypeDatabase.h"
#import "Parsing.h"

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

- (NSString *)logFilePathForWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    if (world == nil)
        return nil;
    return [world.url URLByAppendingPathComponent:@"wine.log"].path;
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

- (NSArray *)argumentsForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    if (world == nil)
        return nil;
    
    StartMenuItem *item = [self startMenuItemForItemPath:itemPath
                                                 inWorld:world];
    if (item == nil)
        return nil;
    
    return splitArguments(item.args);
}

- (void)openFile:(NSString *)file withFiletype:(NSString *)filetypeId inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    [world run:[self programForFile:file withFiletype:filetypeId inWorld:worldName]
 withArguments:[self argumentsForFile:file withFiletype:filetypeId inWorld:worldName]];
}

- (NSString *)programForFile:(NSString *)file withFiletype:(NSString *)filetypeId inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    Filetype *filetype = [self filetypeForId:filetypeId inWorld:world];
    NSString *windowsPath = windowsPathFromUnixPath(file, world);
    return programFromCommand([filetype.command stringByReplacingOccurrencesOfString:@"%1" withString:windowsPath]);
}

- (NSArray *)argumentsForFile:(NSString *)file withFiletype:(NSString *)filetypeId inWorld:(NSString *)worldName {
    World *world = [self worldForName:worldName];
    Filetype *filetype = [self filetypeForId:filetypeId inWorld:world];
    NSString *windowsPath = windowsPathFromUnixPath(file, world);
    return argumentsFromCommand([filetype.command stringByReplacingOccurrencesOfString:@"%1" withString:windowsPath]);
}

- (StartMenuItem *)startMenuItemForItemPath:(NSString *)itemPath inWorld:(World *)world {
    StartMenu *menu;
    if (world == [WorldsController sharedController].selectedWorld)
        menu = [StartMenuController sharedInstance].menu;
    else
        menu = [[StartMenu alloc] initWithWorld:world];
    for (StartMenuItem *item in menu.items) {
        if ([item.itemPath isEqualToString:itemPath]) {
            return item;
        }
    }
    return nil;
}

- (Filetype *)filetypeForId:(NSString *)filetypeId inWorld:(World *)world {
    FiletypeDatabase *filetypes = [StartMenuController sharedInstance].filetypes;
    for (Filetype *filetype in filetypes.filetypes) {
        if ([filetype.docName isEqualToString:filetypeId]) {
            return filetype;
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
