//
//  World.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WinePrefix;

extern NSString *const WorldPasteboardType;

@interface World : NSObject <NSPasteboardReading, NSPasteboardWriting>

+ (World *)worldNamed:(NSString *)name;
+ (void)deleteWorldNamed:(NSString *)name;

@property (readonly) WinePrefix *prefix;

- (void)run:(NSString *)program withArguments:(NSArray *)arguments;
- (void)run:(NSString *)program;

@property (readonly) NSString *name;

@end
