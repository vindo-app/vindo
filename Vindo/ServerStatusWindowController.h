//
//  ServerStatusWindowController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ServerStatusWindowController : NSWindowController

- (instancetype)initWithMessage:(NSString *)message;

- (void)appear;
- (void)disappear;

@property (readonly) NSString *message;

@end
