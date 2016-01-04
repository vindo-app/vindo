//
//  StartMenuItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuItem.h"
#import "World.h"
#import "World+StartMenu.h"
#import "WorldsController.h"

@implementation StartMenuItem

- (instancetype)initWithNativeIdentifier:(NSString *)nativeIdentifier inWorld:(World *)world {
    if (self = [super init]) {
        _nativeIdentifier = nativeIdentifier;
        _world = world;

        NSURL *programsFolder = world.programsFolder;
        NSURL *plistFile = [[programsFolder URLByAppendingPathComponent:nativeIdentifier]
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

        
        _name = itemPlist[@"Name"];
        _path = itemPlist[@"Path"];
        _args = itemPlist[@"Arguments"];

        _iconURL = [[programsFolder URLByAppendingPathComponent:nativeIdentifier]
                                    URLByAppendingPathExtension:@"icns"];
        _icon = [[NSImage alloc] initByReferencingURL:_iconURL];
        
        _bundle = [[AppBundle alloc] initWithStartMenuItem:self];
        NSLog(@"_bundle is %@", _bundle);
        [_bundle generate];
    }
    return self;
}

- (BOOL)isEqual:(StartMenuItem *)item {
    return [self.nativeIdentifier isEqualToString:item.nativeIdentifier];
}

- (NSUInteger)hash {
    return [self.nativeIdentifier hash];
}

- (NSString *)description {
    return self.nativeIdentifier;
}

@end
