//
//  NSObject+Notifications.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/9/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NotificationObserverBlock)(NSNotification *notification);

@interface NSObject (Notifications)

- (void)onNext:(NSString *)notification do:(NotificationObserverBlock)block;
- (void)on:(NSString *)notification do:(NotificationObserverBlock)block;

- (void)on:(NSString *)notification doAction:(SEL)action onTarget:(id)target;

@end
