//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"

static NSMutableDictionary *worldsDictionary;

@implementation World

+ (World *)worldNamed:(NSString *)name {
    if (worldsDictionary[name] == nil)
        worldsDictionary[name] = [[self alloc] initWithName:name];
    return worldsDictionary[name];
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super initWithPath:[self prefixPath:name]]) {
        _name = name;
    }
    return self;
}

+ (World *)defaultWorld {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *worlds = [defaults arrayForKey:@"worlds"];
    NSUInteger defaultWorldIndex = [defaults integerForKey:@"defaultWorldIndex"];
    return [self worldNamed:worlds[defaultWorldIndex]];
}

+ (void)deleteWorldNamed:(NSString *)name {
    [worldsDictionary removeObjectForKey:name];
}

- (NSURL *)prefixPath:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [[[manager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Vindo"];
    return [applicationSupport URLByAppendingPathComponent:name];
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[WorldPasteboardType];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    return [self.name pasteboardPropertyListForType:NSPasteboardTypeString];
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[WorldPasteboardType];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsData;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    return [World worldNamed:[[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:NSPasteboardTypeString]];
}

+ (void)initialize {
    worldsDictionary = [NSMutableDictionary new];
}

@end

NSString *const WorldPasteboardType = @"org.vindo.world";