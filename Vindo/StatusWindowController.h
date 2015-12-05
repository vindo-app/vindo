//
//  ServerStatusWindowController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusWindowController : NSWindowController

- (instancetype)initWithMessage:(NSString *)message
                    sheetWindow:(NSWindow *)window;

@property (readonly) NSString *message;

- (void)appear;
- (void)disappear;

@end
