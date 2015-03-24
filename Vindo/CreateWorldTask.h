//
//  CreateWorldTask.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/24/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "World.h"
#import "WorldTask.h"

@interface CreateWorldTask : WorldTask

- (instancetype)initWithWorldName:(NSString *)worldName arrayController:(NSArrayController *)controller;

@property (readonly) NSString *worldName;
@property (readonly) NSArrayController *controller;

@end
