//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"

@implementation World

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
        _url = [self prefixPath:self.name];
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
    NSTask *task = [self wineTaskWithProgram:@"wine"
                                   arguments:[@[program] arrayByAddingObjectsFromArray:arguments]];
    [task launch];
}

- (void)run:(NSString *)program {
    [self run:program withArguments:@[]];
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

