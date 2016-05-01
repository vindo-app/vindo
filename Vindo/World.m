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

- (void)setup {
    if (self.winebootTask)
        return;

    [self start];
    
    self.winebootTask = [self wineTaskWithProgram:@"wine" arguments:@[@"wineboot", @"--init"]];
    @weakify(self);
    self.winebootTask.terminationHandler = ^(id t) {
        @strongify(self);
        self.winebootTask = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:WorldDidFinishSetupNotification object:self];
    };
    [self.winebootTask launch];
}

- (NSString *)displayName {
    NSString *displayName = [[NSUserDefaults standardUserDefaults] valueForKeyPath:[NSString stringWithFormat:@"displayNames.%@", self.name]];
    if (displayName)
        return displayName;
    else
        return self.name;
}

- (void)setDisplayName:(NSString *)displayName {
    [[NSUserDefaults standardUserDefaults] setValue:displayName forKeyPath:[NSString stringWithFormat:@"displayNames.%@", self.name]];
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