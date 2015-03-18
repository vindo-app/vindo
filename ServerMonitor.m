//
//  ServerMonitor.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ServerMonitor.h"
#import "ServerStatusWindowController.h"
#import "WinePrefix.h"
#import "PrefixesController.h"

@interface ServerMonitor ()

@property ServerStatusWindowController *controller;

@end

@implementation ServerMonitor

- (instancetype)init {
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(wineServerWillStart:) name:WineServerWillStartNotification object:nil];
        [center addObserver:self selector:@selector(wineServerWillStop:) name:WineServerWillStopNotification object:nil];
        [center addObserver:self selector:@selector(wineServerDidSomething:) name:WineServerDidStartNotification object:nil];
        [center addObserver:self selector:@selector(wineServerDidSomething:) name:WineServerDidStopNotification object:nil];
    }
    return self;
}

- (void)wineServerWillStart:(NSNotification *)notification {
    self.controller = [[ServerStatusWindowController alloc] initWithMessage:@"Starting Wine Server..."];
    [self.controller appear];
}

- (void)wineServerWillStop:(NSNotification *)notification {
    self.controller = [[ServerStatusWindowController alloc] initWithMessage:@"Stopping Wine Server..."];
    [self.controller appear];
}

- (void)wineServerDidSomething:(NSNotification *)notification {
    [self.controller disappear];
    self.controller = nil;
}

@end