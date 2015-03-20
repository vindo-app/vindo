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

- (NSArray *)transformedValue:(NSArray *)worldNames {
    NSMutableArray *worlds = [NSMutableArray arrayWithArray:worldNames];
    for (int i = 0; i < [worldNames count]; i++) {
        worlds[i] = [World worldNamed:worldNames[i]];
    }
    return worlds;
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (NSArray *)reverseTransformedValue:(NSArray *)worlds {
    NSMutableArray *worldNames = [NSMutableArray arrayWithArray:worlds];
    for (int i = 0; i < [worlds count]; i++) {
        worldNames[i] = [worlds[i] name];
    }
    return worldNames;
}

@end
