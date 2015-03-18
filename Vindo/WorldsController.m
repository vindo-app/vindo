//
//  PrefixesController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/10/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsController.h"

static WorldsController *controller;

@interface WorldsController () {
    NSMutableArray *worlds;
}

@property NSMutableArray *worlds;
@property NSUInteger selectedWorldIndex;

@end

@implementation WorldsController

- (instancetype)init {
    // double-check locking
    if (controller == nil) {
        @synchronized (self.class) {
            if (controller == nil) {
                if (self = [super init]) {
                    self.worlds = [NSMutableArray new];
                    self.selectedWorldIndex = NSNotFound;
                }
                controller = self;
            }
        }
    }
    return controller;
}

- (WinePrefix *)defaultWorld {
    if (self.selectedWorldIndex == NSNotFound)
        return nil;
    else
        return [self.worlds objectAtIndex:self.selectedWorldIndex];
}

- (void)setDefaultWorld:(WinePrefix *)defaultWorld {
    NSUInteger index = [self.worlds indexOfObjectIdenticalTo:defaultWorld];
    if (index == NSNotFound)
        [NSException raise:NSRangeException format:@"default world is not in worlds controller"];
    else
        self.selectedWorldIndex = index;
}

- (void)addWorld:(WinePrefix *)world {
    [_worlds addObject:world];
}

+ (WorldsController *)sharedController {
    return [self new];
}

+ (WinePrefix *)defaultWorld {
    return [self sharedController].defaultWorld;
}

@end
