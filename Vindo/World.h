//
//  World.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WinePrefix.h"

extern NSString *const WorldPasteboardType;

@interface World : WinePrefix <NSPasteboardReading, NSPasteboardWriting>

+ (World *)worldNamed:(NSString *)name;
+ (World *)defaultWorld;

+ (void)deleteWorldNamed:(NSString *)name;

@property (readonly) NSString *name;

@end
