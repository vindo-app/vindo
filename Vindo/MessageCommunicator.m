//
//  MessageCommunicator.m
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "MessageCommunicator.h"

@interface MessageCommunicator ()

@property SRWebSocket *socket;

@property NSDate *lastMessageTimestamp;

@property NSTimer *reconnectTimer;

@end

@implementation MessageCommunicator

- (instancetype)init {
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [self openSocket];
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(reconnectSocket:) userInfo:nil repeats:YES];
        
        [center addObserver:self
                   selector:@selector(shutdownWebsocket:)
                       name:NSApplicationWillTerminateNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(sendMessage:)
                       name:SendMessageNotification
                     object:nil];
    }
    return self;
}

- (void)sendMessage:(NSNotification *)n {
    Message *message = n.userInfo[@"message"];
    NSDictionary *jsonPayload = @{
                                  @"text": message.text,
                                  @"uuid": self.analytics.uuid,
                                  };
    NSData *payload = [NSJSONSerialization dataWithJSONObject:jsonPayload
                                                        options:0 error:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://homebase.vindo.co/messages"]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", payload.length] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = payload;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *) r;
        NSUInteger statusCode = resp.statusCode;
        if (statusCode != 204) {
            NSLog(@"retrying code = %lu", statusCode);
            [self performSelector:@selector(sendMessage:) withObject:n afterDelay:1];
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageSentNotification object:self userInfo:@{@"message": message}];
    }] resume];
}

- (void)shutdownWebsocket:(NSNotification *)n {
    [self.socket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSData *)data {
    NSError *error;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!json) {
        [NSApp presentError:error];
        return;
    }
    
    if ([json[@"type"] isEqualToString:@"ping"]) {
        return;
    }
    
    if ([json[@"type"] isEqualToString:@"welcome"]) {
        // subscribe
        NSDictionary *subscribeJson = @{
                                        @"command": @"subscribe",
                                        @"identifier": [NSString stringWithFormat:@"{\"channel\":\"MessagesChannel\",\"uuid\":\"%@\"}", self.analytics.uuid]
                                        };
        NSData *data = [NSJSONSerialization dataWithJSONObject:subscribeJson options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [webSocket send:string];
        
        [self refreshMessages];
    }
    
    if (json[@"type"] == nil) {
        // omg a message
        [self messageRecieved:json[@"message"]];
    }
}

- (void)refreshMessages {
    // grab messages since last one
    NSString *url = [NSString stringWithFormat:@"https://homebase.vindo.co/messages?uuid=%@&since=%lu", self.analytics.uuid,
                     (unsigned long) self.lastMessageTimestamp.timeIntervalSince1970 + 1];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *) r;
        if (resp.statusCode != 200) {
            [self performSelector:@selector(refreshMessages) withObject:nil afterDelay:1];
        } else {
            NSArray *messages = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            for (NSDictionary *message in messages) {
                [self messageRecieved:message];
            }
        }
    }] resume];
}

- (void)messageRecieved:(NSDictionary *)messageDict {
    Message *message = [[Message alloc] initFromDictionary:messageDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageRecievedNotification object:self userInfo:@{@"message":message}];
    self.lastMessageTimestamp = message.timestamp;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self openSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self openSocket];
}

- (void)openSocket {
    if (!self.socket || self.socket.readyState == SR_CLOSED) {
        self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://homebase.vindo.co/cable"]];
        self.socket.delegate = self;
        [self.socket open];
    }
}

- (void)reconnectSocket:(NSTimer *)timer {
    [self openSocket];
}

- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
    return NO;
}

@end

NSString *const MessageRecievedNotification = @"MessageRecievedNotification";
NSString *const MessageSentNotification = @"MessageSentNotification";
NSString *const SendMessageNotification = @"SendMessageNotification";
