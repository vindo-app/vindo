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
                    sheetWindow:(NSWindow *)window
              startNotification:(NSString *)startNotification
               stopNotification:(NSString *)stopNotification
                         object:(id)object;

@property (readonly) NSString *message;

@end
