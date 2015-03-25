//
//  DeleteWorldTask.m
//  Vindo
//
//  Created by Theodore Dubois on 3/25/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "DeleteWorldTask.h"
#import "WineServerOperations.h"

@implementation DeleteWorldTask

- (id)initWithArrayController:(NSArrayController *)controller
                  sheetWindow:(NSWindow *)window {
    NSString *description;
    if (controller.selectedObjects.count == 1)
        description = [NSString stringWithFormat:@"Deleting world \"%@\"…",
                       [controller.selectedObjects.firstObject name]];
    else
        description = [NSString stringWithFormat:@"Deleting %lu worlds…",
                       (unsigned long) controller.selectedObjects.count];
    if (self = [super initWithTaskDescription:description
                                  sheetWindow:window]) {
        _worldsToDelete = controller.selectedObjects;
        _controller = controller;
    }
    return self;
}

- (void)main {
    for (World *world in _worldsToDelete) {
        [[[StopWineServerOperation alloc] initWithPrefix:world] start]; // stop server
        [[NSFileManager defaultManager]
         trashItemAtURL:world.path resultingItemURL:nil error:nil]; // move world to trash
        [_controller removeObject:world]; // remove object from worlds
        [World deleteWorldNamed:world.name];
    }
}

@end
