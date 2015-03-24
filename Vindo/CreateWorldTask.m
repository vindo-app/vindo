//
//  CreateWorldTask.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/24/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "CreateWorldTask.h"
#import "WineServerOperations.h"

@implementation CreateWorldTask

- (instancetype)initWithWorldName:(NSString *)worldName arrayController:(NSArrayController *)arrayController {
    if (self = [super initWithTaskDescription:[NSString stringWithFormat:@"Creating world \"%@\"…", worldName]]) {
        _worldName = worldName;
        _controller = arrayController;
    }
    return self;
}

- (void)main {
    World *world = [World worldNamed:_worldName];
    [[[StartWineServerOperation alloc] initWithPrefix:world] start]; // run inline
    [_controller addObject:world];
    _controller.selectedObjects = @[world];
}

@end
