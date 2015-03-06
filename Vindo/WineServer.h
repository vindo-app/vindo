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

@interface WineServer : NSObject

- (id)initWithPrefix:(NSString *)prefix;

+ (WineServer *)defaultServer;

- (void)start;
- (void)stop;

- (void)runExe:(NSString *)exePath;

- (void)makeDefaultServer;

@property (readonly) NSString *prefix;

@end
