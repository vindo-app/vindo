//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "WinePrefix.h"

static NSMutableDictionary *worldsDictionary;

@implementation World

+ (World *)worldNamed:(NSString *)name {
    if (worldsDictionary[name] == nil)
        worldsDictionary[name] = [[self alloc] initWithName:name];
    return worldsDictionary[name];
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
        _prefix = [[WinePrefix alloc] initWithPrefixURL:[self prefixPath:self.name]];
    }
    return self;
}

+ (void)deleteWorldNamed:(NSString *)name {
    [worldsDictionary removeObjectForKey:name];
}

- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    NSTask *task = [self.prefix wineTaskWithProgram:@"wine"
                                          arguments:[@[program] arrayByAddingObjectsFromArray:arguments]];
    [task launch];
}

- (void)run:(NSString *)program {
    [self run:program withArguments:@[]];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:World.class] && [[object name] isEqualToString:self.name];
}

- (NSUInteger)hash {
    return self.name.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>", self.class, self.name];
}

- (NSURL *)prefixPath:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [[[manager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Vindo"];
    return [applicationSupport URLByAppendingPathComponent:name];
}

#pragma mark Pasteboard Stuff

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
    return [World worldNamed:
            [[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:NSPasteboardTypeString]];
}

@end

NSString *const WorldPasteboardType = @"org.vindo.world";
