//
//  DeleteWorldTask.h
//  Vindo
//
//  Created by Theodore Dubois on 3/25/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "World.h"
#import "WorldTask.h"

@interface DeleteWorldTask : WorldTask

- (instancetype)initWithArrayController:(NSArrayController *)controller
                            sheetWindow:(NSWindow *)window;

@property (readonly) NSArray *worldsToDelete;
@property (readonly) NSArrayController *controller;

@end
