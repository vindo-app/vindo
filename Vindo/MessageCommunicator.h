//
//  MessageCommunicator.h
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SocketRocket/SocketRocket.h>
#import "Message.h"
#import "AnalyticsController.h"

extern NSString *const MessageRecievedNotification;
extern NSString *const MessageSentNotification;
extern NSString *const SendMessageNotification;

@interface MessageCommunicator : NSObject <SRWebSocketDelegate>

@property AnalyticsController *analytics;

@end
