//
//  WorldTask.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/24/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const WorldTaskWillRunNotification;
extern NSString *const WorldTaskDidRunNotification;

@interface WorldTask : NSOperation

- (instancetype)initWithTaskDescription:(NSString *)taskDescription
                            sheetWindow:(NSWindow *)window;

@property (readonly) NSString *taskDescription;

@end
