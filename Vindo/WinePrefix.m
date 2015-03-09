//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WinePrefix.h"

static NSString *usrPath;

#pragma mark Private Interfaces

@interface StartWineServerOperation : NSOperation

- (id)initWithPrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@property NSTask *server;

@end


@interface StopWineServerOperation : NSOperation

- (id)initWithPrefix:(WinePrefix *)prefix serverTask:(NSTask *)server;

@property (readonly, strong) WinePrefix *prefix;

@property NSTask *server;

@end


@interface WinePrefix ()

@property StartWineServerOperation *startOp;
@property StopWineServerOperation *stopOp;

@end

#pragma mark Implementations

@implementation WinePrefix

- (id)initWithPath:(NSURL *)prefixPath {
    if (self = [super init]) {
        _path = prefixPath;
        
        // make sure prefix directory exists
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager createDirectoryAtURL:self.path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil])
            [NSException raise:NSGenericException format:@"could not create prefix directory %@", self.path];
        
        self.startOp = [[StartWineServerOperation alloc] initWithPrefix:self];
        self.stopOp = [[StopWineServerOperation alloc] initWithPrefix:self
                                                            serverTask:self.startOp.server];
    }
    return self;
}

static NSOperationQueue *ops;

- (void)startServer {
    [ops addOperation:self.startOp];
}

- (void)stopServer {
    [ops addOperation:self.stopOp];
}

- (BOOL)isServerRunning {
    if (self.startOp.isExecuting)
        return NO;
    if (self.startOp.server != nil)
        return [self.startOp.server isRunning];
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

- (void)dealloc {    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
}

+ (void)initialize {
    if (self == [WinePrefix self]) {
        usrPath = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"usr"];
        
        if (ops == nil)
            ops = [NSOperationQueue new];
    }
}

@end

#pragma mark Operations

@implementation StartWineServerOperation

- (id)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init])
        _prefix = prefix;
    return self;
}

- (void)main {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStartNotification object:self.prefix];
        
        self.server = [NSTask new];
        self.server.launchPath = [usrPath stringByAppendingPathComponent:@"bin/wineserver"];
        self.server.arguments = [NSArray arrayWithObjects:@"-f", nil]; // stay in foreground
        self.server.environment = _prefix.wineEnvironment;
        self.server.standardInput = [NSFileHandle fileHandleWithNullDevice];
        self.server.standardOutput = [self logFileHandle];
        self.server.standardError = [self logFileHandle];
        
        if (self.isCancelled) {
            return;
        }
        
        [center addObserver:self
                   selector:@selector(serverTaskStopped:)
                       name:NSTaskDidTerminateNotification
                     object:self.server];
        [self.server launch];
        
        if (self.isCancelled) {
            [self.server terminate];
            [self.server waitUntilExit];
            return;
        }
        
        [center postNotificationName:WineServerDidStartNotification object:self.prefix];
        
        if (self.isCancelled) {
            [self.server terminate];
            [self.server waitUntilExit];
            return;
        }
    }
    @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

- (void)serverTaskStopped:(NSNotification *)notification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    NSString *stopNotification;
    if (_server.terminationStatus == 0)
        stopNotification = WineServerDidStopNotification;
    else
        stopNotification = WineServerDidCrashNotification;
    
    [center postNotificationName:stopNotification
                          object:self
                        userInfo:
     [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_server.terminationStatus]
                                 forKey:kWineServerExitStatus]];
}

- (NSFileHandle *)logFileHandle {
    // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
    NSString *logFilePath = [[_prefix.path URLByAppendingPathComponent:@"wine.log"] path];
    int logFileDescriptor = open([logFilePath UTF8String],
                                 O_WRONLY | O_CREAT | O_APPEND,
                                 0644); // mode: -rw-r--r--
    
    if (logFileDescriptor < 0)
        [NSException raise:NSGenericException format:@"error opening file: %s", strerror(errno)];
    
    return [[NSFileHandle alloc] initWithFileDescriptor:logFileDescriptor closeOnDealloc:YES];
}

@end


@implementation StopWineServerOperation

- (id)initWithPrefix:(WinePrefix *)prefix serverTask:(NSTask *)server {
    if (self = [super init]) {
        _prefix = prefix;
        self.server = server;
    }
    return self;
}

- (void)main {
    if (_prefix.startOp.isExecuting) {
        [_prefix.startOp cancel];
        [_prefix.startOp waitUntilFinished];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center postNotificationName:WineServerWillStopNotification object:self.prefix];
    [_server terminate];
    [_server waitUntilExit];
}

@end

#pragma mark Notification Constants

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";

NSString *const kWineServerExitStatus = @"kWineServerExitStatus";
