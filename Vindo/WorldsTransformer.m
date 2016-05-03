//
//  WorldsTransformer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/20/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsTransformer.h"
#import "World.h"

@implementation WorldsTransformer

+ (Class)transformedValueClass {
    return [NSArray class];
}

- (NSArray *)transformedValue:(NSArray *)worldIds {
    NSMutableArray *worlds = [NSMutableArray arrayWithArray:worldIds];
    for (int i = 0; i < [worldIds count]; i++) {
        worlds[i] = [[World alloc] initWithId:worldIds[i]];
    }
    return worlds;
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (NSArray *)reverseTransformedValue:(NSArray *)worlds {
    NSMutableArray *worldIds = [NSMutableArray arrayWithArray:worlds];
    for (int i = 0; i < [worlds count]; i++) {
        worldIds[i] = [worlds[i] worldId];
    }
    return worldIds;
}

@end
