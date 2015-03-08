//
//  WineServer.h
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const WineServerWillStartNotification;
extern NSString *const WineServerDidStartNotification;
extern NSString *const WineServerWillStopNotification;
extern NSString *const WineServerDidStopNotification;
extern NSString *const WineServerDidCrashNotification;

extern NSString *const kWineServerExitStatus;

@interface WinePrefix : NSObject

- (id)initWithPath:(NSURL *)path;

- (void)startServer;
- (void)stopServer;

- (void)run:(NSString *)exePath;

@property (readonly) NSURL *path;

@end
