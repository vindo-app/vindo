//
//  PrefixesController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/10/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinePrefix.h"

@interface WorldsController : NSObject

+ (WorldsController *)sharedController;
+ (WinePrefix *)defaultWorld;

- (void)addWorld:(WinePrefix *)world;
- (void)removeWorld:(WinePrefix *)world;

@property (readonly) NSArray *worlds;
@property WinePrefix *defaultWorld;

@end
