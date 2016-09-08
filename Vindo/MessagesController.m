//
//  MessagesController.m
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "MessagesController.h"
#import "MessageCommunicator.h"
#import "MessagesWindowController.h"
#import "AnalyticsController.h"

@interface MessagesController ()

@property IBOutlet AnalyticsController *analytics;

@property NSMutableArray *messages;
@property NSUInteger unreadCount;

@property MessageCommunicator *communicator;
@property MessagesWindowController *mwc;

@end

@implementation MessagesController

- (void)awakeFromNib {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                             @"lastNotificationTimestamp": [NSDate distantPast],
                                                             }];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    self.communicator = [MessageCommunicator new];
    self.communicator.analytics = self.analytics;
    self.mwc = [MessagesWindowController new];
    self.mwc.messagesController = self;
    self.mwc.window.isVisible = NO;
    
    [center addObserver:self
               selector:@selector(showMessages:)
                   name:ShowMessagesWindowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(messagesWindowAppeared:)
                   name:NSWindowDidChangeOcclusionStateNotification
                 object:self.mwc.window];
    
    self.messages = [NSMutableArray new];
    [center addObserver:self
               selector:@selector(addMessage:)
                   name:MessageRecievedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(addMessage:)
                   name:MessageSentNotification
                 object:nil];
}

- (void)addMessage:(NSNotification *)n {
    Message *message = n.userInfo[@"message"];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:self.messages.count] forKey:@"messages"];
    [self.messages addObject:message];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:self.messages.count - 1] forKey:@"messages"];
    NSDate *lastNotificationTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastNotificationTimestamp"];
    NSLog(@"comparing %@ (new message timestamp) to %@ (lnt)", message.timestamp, lastNotificationTimestamp);
    if (!message.fromUser && [message.timestamp compare:lastNotificationTimestamp] == NSOrderedDescending) {
        NSLog(@"descending");
        if (!self.mwc.window.visible)
            self.unreadCount++;
        [self deliverUserNotification:message];
        [[NSUserDefaults standardUserDefaults] setObject:message.timestamp forKey:@"lastNotificationTimestamp"];
    }
}

- (void)deliverUserNotification:(Message *)message {
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = @"Vindo HQ";
    notification.informativeText = message.text;
    notification.hasReplyButton = YES;
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    unc.delegate = self;
    [unc deliverNotification:notification];
    NSLog(@"delivered notification");
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    if (notification.activationType == NSUserNotificationActivationTypeReplied) {
        NSLog(@"responding");
        if (notification.response.length == 0)
            return;
        Message *message = [[Message alloc] initWithText:notification.response.string];
        [[NSNotificationCenter defaultCenter] postNotificationName:SendMessageNotification object:self userInfo:@{@"message":message}];
    } else if (notification.activationType == NSUserNotificationActivationTypeContentsClicked) {
        [self showMessages:nil];
    }
}

- (void)showMessages:(NSNotification *)n {
    self.mwc.window.isVisible = YES;
    [self.mwc showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)messagesWindowAppeared:(NSNotification *)n {
    if (self.mwc.window.isVisible) {
        NSLog(@"window appeared, zeroing unread count");
        self.unreadCount = 0;
    }
}

- (NSUInteger)unreadCount {
    return _unreadCount;
}

- (void)setUnreadCount:(NSUInteger)unreadCount {
    _unreadCount = unreadCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:SetUnreadMessagesCountNotification object:self userInfo:@{@"unreadCount":@(unreadCount)}];
}

@end

const NSString *const ShowMessagesWindowNotification = @"ShowMessagesWindowNotification";
const NSString *const SetUnreadMessagesCountNotification = @"SetUnreadMessagesCountNotification";
