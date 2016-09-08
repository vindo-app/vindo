//
//  MessagesController.h
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SetUnreadMessagesCountNotification;
extern NSString *const ShowMessagesWindowNotification;

@interface MessagesController : NSObject <NSUserNotificationCenterDelegate> {
    NSUInteger _unreadCount;
}

@property (readonly) NSMutableArray *messages;

@end
