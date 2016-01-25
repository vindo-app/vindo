//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "NSUserDefaults+KeyPaths.h"

static NSMapTable *worlds;

@interface World ()

@property NSTask *winebootTask;

@end

@implementation World

- (instancetype)initWithName:(NSString *)name {
    if (worlds == nil)
        worlds = [NSMapTable strongToWeakObjectsMapTable];
    
    if ([worlds objectForKey:name])
        return [worlds objectForKey:name];
    
    if (self = [super init]) {
        _name = name;
        _url = [self prefixPath:self.name];
        
        [worlds setObject:self forKey:name];
    }
    return self;
}

- (NSURL *)prefixPath:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [[manager URLsForDirectory:NSApplicationSupportDirectory
                                                 inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"Vindo/Worlds"];
    return [applicationSupport URLByAppendingPathComponent:name];
}

- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    [self start];
    NSTask *task = [self wineTaskWithProgram:@"wine"
                                   arguments:[@[program] arrayByAddingObjectsFromArray:arguments]];
    [task launch];
}

- (void)run:(NSString *)program {
    [self run:program withArguments:@[]];
}

// FIXME: that warning is right, weakify
- (void)setup {
    if (self.winebootTask)
        return;

    [self start];
    
    self.winebootTask = [self wineTaskWithProgram:@"wine" arguments:@[@"wineboot", @"--init"]];
    self.winebootTask.terminationHandler = ^(id t) {
        NSLog(@"termination happened");
        self.winebootTask = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:WorldDidFinishSetupNotification object:self];
    };
    [self.winebootTask launch];
    NSLog(@"wineboot pid: %d", self.winebootTask.processIdentifier);
}

- (NSString *)displayName {
    NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKeyPath:[NSString stringWithFormat:@"displayNames.%@", self.name]];
    if (displayName)
        return displayName;
    else
        return self.name;
}

- (void)setDisplayName:(NSString *)displayName {
    [[NSUserDefaults standardUserDefaults] setObject:displayName forKeyPath:[NSString stringWithFormat:@"displayNames.%@", self.name]];
}

#pragma mark -
#pragma mark Random crap

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:World.class] && [[object name] isEqualToString:self.name];
}

- (NSUInteger)hash {
    return self.name.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>", self.class, self.name];
}

@end

NSString *const WorldDidFinishSetupNotification = @"WorldDidFinishSetupNotification";