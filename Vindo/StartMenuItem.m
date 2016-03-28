//
//  StartMenuItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuItem.h"
#import "World.h"
#import "Filetype.h"
#import "FiletypeDatabase.h"
#import "StartMenuController.h"
#import "World+StartMenu.h"
#import "WorldsController.h"
#import "NSUserDefaults+KeyPaths.h"

@implementation StartMenuItem

- (instancetype)initWithItemPath:(NSString *)itemPath inWorld:(World *)world {
    if (self = [super init]) {
        _itemPath = itemPath;
        _world = world;
        
        NSURL *programsFolder = world.programsFolder;
        NSURL *plistFile = [[programsFolder URLByAppendingPathComponent:itemPath]
                            URLByAppendingPathExtension:@"plist"];
        
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfURL:plistFile options:0 error:&error];
        NSDictionary *itemPlist;
        if (fileData) {
            itemPlist = [NSPropertyListSerialization propertyListWithData:fileData
                                                                  options:NSPropertyListImmutable
                                                                   format:NULL
                                                                    error:&error];
        }
        if (error) {
            NSLog(@"%@", error);
            return nil;
        }
        
        _name = [itemPlist[@"Name"] lastPathComponent];
        _path = itemPlist[@"Path"];
        _args = itemPlist[@"Arguments"];
        _explanation = itemPlist[@"Description"];
        
        _iconURL = [[programsFolder URLByAppendingPathComponent:itemPath]
                    URLByAppendingPathExtension:@"icns"];
        _icon = [[NSImage alloc] initByReferencingURL:_iconURL];
        
        _bundle = [[AppBundle alloc] initWithStartMenuItem:self];
        [self findFiletypes];
        [_bundle generate];
    }
    return self;
}

- (void)findFiletypes {
    NSArray *filetypes = [StartMenuController sharedInstance].filetypes.filetypes;
    for (Filetype *filetype in filetypes) {
        if ([filetype.appName isEqualToString:self.name]) {
            NSLog(@"%@: found filetype %@", self.name, filetype.docName);
            [_bundle addFiletype:filetype];
        }
    }
}

- (NSUInteger)subrank {
    NSUInteger subrank = [[[NSUserDefaults standardUserDefaults] valueForKeyPathArray:@[@"subrank", self.world.name, self.itemPath]]
                          unsignedIntegerValue];
    if (subrank == 0) {
        subrank = self.subrank = 10;
    }
    return subrank;
}

- (void)setSubrank:(NSUInteger)subrank {
    [[NSUserDefaults standardUserDefaults] setValue:@(subrank) forKeyPathArray:@[@"subrank", self.world.name, self.itemPath]];
}

- (NSString *)tooltip {
    if (self.explanation)
        return [NSString stringWithFormat:@"%@\n%@", self.name, self.explanation];
    else
        return self.name;
}

- (NSArray<NSString *> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [[self.bundle.bundleURL writableTypesForPasteboard:pasteboard] arrayByAddingObject:StartMenuItemPasteboardType];
}
- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:StartMenuItemPasteboardType])
        return [NSData dataWithBytes:&self length:sizeof(self)];
    return [self.bundle.bundleURL pasteboardPropertyListForType:type];
}

- (BOOL)isEqual:(StartMenuItem *)item {
    return [self.itemPath isEqualToString:item.itemPath];
}

- (NSUInteger)hash {
    return [self.itemPath hash];
}

- (NSString *)description {
    return self.itemPath;
}

@end

NSString *const StartMenuItemPasteboardType = @"co.vindo.StartMenuItem";