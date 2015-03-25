//
//  WorldTask.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/24/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldTask.h"
#import "StatusWindowController.h"

@interface WorldTask ()

@property StatusWindowController *status;

@end

@implementation WorldTask

- (instancetype)initWithTaskDescription:(NSString *)taskDescription
                            sheetWindow:(NSWindow *)window {
    if (self = [super init]) {
        _taskDescription = taskDescription;
        _status = [[StatusWindowController alloc] initWithMessage:taskDescription
                                                      sheetWindow:window
                                                startNotification:WorldTaskWillRunNotification
                                                 stopNotification:WorldTaskDidRunNotification
                                                           object:self];
    }
    return self;
}

- (void)start {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WorldTaskWillRunNotification object:self];
        [super start];
        [center postNotificationName:WorldTaskDidRunNotification object:self];
    } @catch (NSException *exception) {
        // do nothing
    }
}

@end

NSString *const WorldTaskWillRunNotification = @"WorldTaskWillRunNotification";
NSString *const WorldTaskDidRunNotification = @"WorldTaskDidRunNotification";