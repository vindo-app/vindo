//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "Parsing.h"
#import "World.h"
#import <libextobjc/extobjc.h>

static NSMapTable *worlds;

@interface World ()

@property NSTask *winebootTask;

@end

@implementation World

- (instancetype)initWithId:(NSString *)worldId {
    if ([worlds objectForKey:worldId])
        return [worlds objectForKey:worldId];
    if (self = [super init]) {
        _worldId = worldId;
        _url = [self prefixURL:worldId];
        if (worlds == nil)
            worlds = [NSMapTable strongToWeakObjectsMapTable];
        [worlds setObject:self forKey:worldId];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    NSString *worldId = @"";
    for (int i = 0; i < 20; i++)
        worldId = [worldId stringByAppendingFormat:@"%c", (arc4random() % 26) + 'a'];
    self = [self initWithId:worldId];
    self.name = name;
    return self;
}

- (NSURL *)prefixURL:(NSString *)worldId {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [[manager URLsForDirectory:NSApplicationSupportDirectory
                                                 inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"Vindo/Worlds"];
    return [applicationSupport URLByAppendingPathComponent:worldId];
}


- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    NSTask *task = [self wineTaskWithProgram:@"wine"
                                   arguments:[@[program] arrayByAddingObjectsFromArray:arguments]];
    [task launch];
}

- (void)run:(NSString *)program {
    [self run:program withArguments:@[]];
}

- (void)setup {
    if (self.winebootTask)
        return;
    
    self.winebootTask = [self wineTaskWithProgram:@"wine" arguments:@[@"wineboot", @"--init"]];
    @weakify(self);
    self.winebootTask.terminationHandler = ^(id t) {
        @strongify(self);
        self.winebootTask = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:WorldDidFinishSetupNotification object:self];
    };
    [self.winebootTask launch];
}

- (NSString *)name {
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKeyPath:[NSString stringWithFormat:@"displayNames.%@", self.worldId]];
    if (name)
        return name;
    else
        return self.worldId;
}

- (void)setName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setValue:name forKeyPath:[NSString stringWithFormat:@"displayNames.%@", self.worldId]];
}

#pragma mark -
#pragma mark Random crap

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:World.class] && [[object worldId] isEqualToString:self.worldId];
}

- (NSUInteger)hash {
    return self.worldId.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ (%@)>", self.class, self.worldId, self.name];
}

@end

NSString *const WorldDidFinishSetupNotification = @"WorldDidFinishSetupNotification";