//
//  WineServer.h
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WinePrefix;

extern NSString *const WineServerWillStartNotification;
extern NSString *const WineServerDidStartNotification;
extern NSString *const WineServerWillStopNotification;
extern NSString *const WineServerDidStopNotification;

@interface WineServer : NSObject

@property (readonly) WinePrefix *prefix;

- (instancetype)initWithPrefix:(WinePrefix *)prefix;

@property (readonly) BOOL running;

- (void)start;
- (void)stop;

- (void)startAndWait;
- (void)stopAndWait;

@end
