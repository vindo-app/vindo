//
//  NSObject+Notifications.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/9/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "NSObject+Notifications.h"

@implementation NSObject (Notifications)

- (void)onNext:(NSString *)notification do:(NotificationObserverBlock)block {
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notification
                                                                            object:self
                                                                             queue:[NSOperationQueue mainQueue]
                                                                        usingBlock:^(NSNotification *note) {
                                                                            [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                            block(note);
                                                                        }];
}

- (void)on:(NSString *)notification do:(NotificationObserverBlock)block {
    [[NSNotificationCenter defaultCenter] addObserverForName:notification
                                                      object:self
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:block];
}

@end
