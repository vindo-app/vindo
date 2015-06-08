//
//  WorldsController.h
//  Vindo
//
//  Created by Theodore Dubois on 6/5/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "World.h"

@interface WorldsController : NSArrayController

+ (WorldsController *)sharedController;

- (World *)selectedWorld;

@end
