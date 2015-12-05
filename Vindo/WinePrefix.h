//
//  WinePrefix.h
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WineServer;

@interface WinePrefix : NSObject

@property NSURL *prefixURL;

- (instancetype)initWithPrefixURL:(NSURL *)prefixURL;

@property WineServer *server;

- (void)startServer;
- (void)stopServer;

- (NSTask *)wineTaskWithProgram:(NSString *)program arguments:(NSArray *)arguments;

@end
