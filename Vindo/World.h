//
//  World.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const WineServerWillStartNotification;
extern NSString *const WineServerDidStartNotification;
extern NSString *const WineServerWillStopNotification;
extern NSString *const WineServerDidStopNotification;
extern NSString *const WineServerDidCrashNotification;

typedef NS_ENUM(NSInteger, WineServerState) {
    WineServerRunning,
    WineServerStarting,
    WineServerStopping,
    WineServerStopped
};
extern NSString *const WorldPasteboardType;

@interface World : NSObject <NSPasteboardReading, NSPasteboardWriting>

+ (World *)worldNamed:(NSString *)name;
+ (World *)defaultWorld;

+ (void)deleteWorldNamed:(NSString *)name;

- (void)start;
- (void)stop;

- (void)startAndWait;
- (void)stopAndWait;

- (void)run:(NSString *)program;
- (void)run:(NSString *)program withArguments:(NSArray *)arguments;

@property (readonly) NSString *name;

@property (readonly) NSURL *path;
@property (readonly) WineServerState state;

@end
