//
//  WineServer.h
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *WineServerWillStartNotification;
extern NSString *WineServerDidStartNotification;

@interface WinePrefix : NSObject

- (id)initWithPath:(NSURL *)path;

- (void)startServer;
- (void)stopServer;

- (void)run:(NSString *)exePath;

@property (readonly) NSURL *path;

@end
