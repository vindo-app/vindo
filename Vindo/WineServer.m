//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServer.h"

static WineServer *defaultServer;
static NSString *usrPath;

NSString *WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *WineServerDidStartNotification = @"WineServerDidStartNotification";

@interface WineServer ()

@property NSTask *server;
@property (readonly) NSString *usrPath;
@property (readonly) NSDictionary *wineEnvironment;

@end

@implementation WineServer
@synthesize prefix;
@synthesize server;
@synthesize wineEnvironment;

- (id)initWithPrefix:(NSString *)prefixPath {
    if (self = [super init])
        prefix = prefixPath;
    return self;
}

+ (WineServer *)defaultServer {
    return defaultServer;
}

- (void)start {
    [NSThread detachNewThreadSelector:@selector(startInThread:) toTarget:self withObject:nil];
}

- (void)startInThread:(id)dummy {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:WineServerWillStartNotification object:self];
    
    server = [NSTask new];
    server.launchPath = [self.usrPath stringByAppendingPathComponent:@"bin/wineserver"];
    server.arguments = [NSArray arrayWithObjects:@"-f", nil]; // stay in foreground
    server.environment = self.wineEnvironment;
    [server launch];
    
    [center postNotificationName:WineServerDidStartNotification object:self];
}

- (void)stop {
    
}

- (void)runExe:(NSString *)exePath {
    NSAlert *alert = [NSAlert alertWithMessageText:@"That option does nothing"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"That's because this is a non-functioning prototype."];
    [alert runModal];
}

- (NSString *)usrPath {
    if (usrPath == nil)
        usrPath = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"usr"];
    return usrPath;
}

- (NSDictionary *)wineEnvironment {
    if (wineEnvironment == nil)
        wineEnvironment = [NSDictionary dictionaryWithObjectsAndKeys:
                           self.prefix, @"WINEPREFIX",
                           [self.usrPath stringByAppendingPathComponent:@"bin"], @"PATH", nil];
    return wineEnvironment;
}

- (void)makeDefaultServer {
    defaultServer = self;
}

@end
