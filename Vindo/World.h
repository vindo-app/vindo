//
//  World.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinePrefix.h"

@interface World : WinePrefix

+ (World *)worldNamed:(NSString *)name;
+ (World *)defaultWorld;

+ (void)deleteWorldNamed:(NSString *)name;

@property (readonly) NSString *name;

@end
