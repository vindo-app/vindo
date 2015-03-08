//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WinePrefix.h"

static NSString *usrPath;

NSString *WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *WineServerDidStartNotification = @"WineServerDidStartNotification";

@interface WinePrefix ()

@property (atomic, assign) BOOL isStarting;
@property NSTask *server;
@property (readonly) NSDictionary *wineEnvironment;
@property (readonly) NSFileHandle *logFileHandle;

@end

@implementation WinePrefix
@synthesize path;
@synthesize server;
@synthesize wineEnvironment;

- (id)initWithPath:(NSURL *)prefixPath {
    if (self = [super init]) {
        path = [prefixPath retain];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager createDirectoryAtURL:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil])
            [NSException raise:NSGenericException format:@"could not create prefix directory %@", path];
    }
    return self;
}

- (void)startServer {
    [NSApplication detachDrawingThread:@selector(startInThread:) toTarget:self withObject:nil];
}

- (void)startInThread:(id)dummy {
    if ([self isServerRunning])
        return;
    
    self.isStarting = YES;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:WineServerWillStartNotification object:self];
    
    self.server = [NSTask new];
    self.server.launchPath = [usrPath stringByAppendingPathComponent:@"bin/wineserver"];
    self.server.arguments = [NSArray arrayWithObjects:@"-f", nil]; // stay in foreground
    self.server.environment = self.wineEnvironment;
    self.server.standardInput = [NSFileHandle fileHandleWithNullDevice];
    self.server.standardOutput = [self logFileHandle];
    self.server.standardError = [self logFileHandle];
    
    [self.server launch];
    
    [center postNotificationName:WineServerDidStartNotification object:self];
    
    self.isStarting = NO;
}

- (void)stopServer {
    [self.server terminate];
}

- (BOOL)isServerRunning {
    if (self.isStarting)
        return NO;
    if (self.server != nil)
        return [self.server isRunning];
    else
        return NO;
}

- (void)run:(NSString *)exePath {
    NSAlert *alert = [NSAlert alertWithMessageText:@"That option does nothing"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"That's because this is a non-functioning prototype."];
    [alert runModal];
}

- (NSDictionary *)wineEnvironment {
    return [NSDictionary dictionaryWithObjectsAndKeys:
                                          [self.path path], @"WINEPREFIX",
           [usrPath stringByAppendingPathComponent:@"bin"], @"PATH", nil];
}

- (NSFileHandle *)logFileHandle {
    // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
    NSString *logFilePath = [[path URLByAppendingPathComponent:@"wine.log"] path];
    int logFileDescriptor = open([logFilePath UTF8String],
                                     O_WRONLY | O_CREAT | O_APPEND,
                                     S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if (logFileDescriptor < 0) {
        [NSException raise:NSGenericException format:@"error opening file: %s", strerror(errno)];
    }
    return [[[NSFileHandle alloc] initWithFileDescriptor:logFileDescriptor closeOnDealloc:YES] autorelease];
}

- (void)dealloc {
    [path release];
    
    [super dealloc];
}

+ (void)initialize {
    if (self == [WinePrefix self])
        usrPath = [[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"usr"] retain];
}

@end
