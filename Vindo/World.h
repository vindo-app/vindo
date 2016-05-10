//
//  World.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const WorldPasteboardType;

@interface World : NSObject <NSPasteboardReading, NSPasteboardWriting>

#pragma mark -
#pragma mark World

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithId:(NSString *)worldId;

@property (readonly) NSString *worldId;
@property NSString *name;
@property (readonly) NSURL *url;

- (void)run:(NSString *)program withArguments:(NSArray *)arguments;
- (void)run:(NSString *)program;
- (void)setup;

#pragma mark -
#pragma mark Server variables

@property NSTask *serverTask;

@end


@interface World (WinePrefix)

- (NSTask *)wineTaskWithProgram:(NSString *)program arguments:(NSArray *)arguments;
- (NSDictionary *)wineEnvironment;

@end

@interface World (WineServer)

- (void)start;
- (void)stop;

@end

extern NSString *const WorldDidStopNotification;
extern NSString *const WorldDidFinishSetupNotification;