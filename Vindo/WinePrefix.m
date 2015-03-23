//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WinePrefix.h"
#import "WineServerOperations.h"

static NSURL *usrURL;

@interface WinePrefix ()

@property StartWineServerOperation *startOp;
@property StopWineServerOperation *stopOp;

@property NSTask *server;

@end

@implementation WinePrefix

- (instancetype)initWithPath:(NSURL *)prefixPath {
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
        self.stopOp = [[StopWineServerOperation alloc] initWithPrefix:self];
        
        // make sure to stop the server when the app is about to terminate
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(stopServerFromNotification:)
                       name:NSApplicationWillTerminateNotification
                     object:NSApp];
    }
    return self;
}

static NSOperationQueue *ops;

#pragma mark Public Interfaces

- (void)startServer {
    if (self.server != nil && self.server.isRunning)
        return;
    [ops addOperation:self.startOp];
    
}

- (void)stopServer {
    if (self.startOp.isExecuting) {
        [self.startOp cancel];
        [self.startOp waitUntilFinished];
    }
    if (self.server == nil || !self.server.isRunning)
        return;
    [ops addOperation:self.stopOp];
}

- (void)stopServerFromNotification:(NSNotification *)notification {
    [self stopServer];
    [self.stopOp waitUntilFinished];
}

- (BOOL)isServerRunning {
    if (self.startOp.isExecuting)
        return NO;
    if (self.server != nil)
        return [self.server isRunning];
    else
        return NO;
}

- (void)run:(NSString *)program {
    RunOperation *runOp = [[RunOperation alloc] initWithPrefix:self program:program arguments:@[]];
    [ops addOperation:runOp];
}

- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    RunOperation *runOp = [[RunOperation alloc] initWithPrefix:self program:program arguments:arguments];
    [ops addOperation:runOp];
}

#pragma mark Task Creaters

- (NSTask *)taskWithWindowsProgram:(NSString *)program arguments:(NSArray *)arguments {
    NSString *currentDirectory;
    if ([program rangeOfString:@"/"].location == NSNotFound) // quick and dirty
        currentDirectory = NSHomeDirectory();
    else
        currentDirectory = [program stringByDeletingLastPathComponent];
    
    return [self taskWithProgram:@"wine"
                       arguments:[@[program] arrayByAddingObjectsFromArray:arguments]
                currentDirectory:currentDirectory];
}

- (NSTask *)taskWithProgram:(NSString *)program arguments:(NSArray *)arguments {
    return [self taskWithProgram:program
                       arguments:arguments
                currentDirectory:NSHomeDirectory()];
}

- (NSTask *)taskWithProgram:(NSString *)program
                  arguments:(NSArray *)arguments
           currentDirectory:(NSString *)currentDirectory {
    NSTask *task = [NSTask new];
    task.launchPath = [[[usrURL URLByAppendingPathComponent:@"bin"]
                        URLByAppendingPathComponent:program]
                       path];
    task.arguments = arguments;
    task.environment = self.wineEnvironment;
    task.currentDirectoryPath = currentDirectory;
    task.standardInput = [NSFileHandle fileHandleWithNullDevice];
    task.standardOutput = [self logFileHandle];
    task.standardError = [self logFileHandle];
    
    return task;
}

#pragma mark Utilities for Task Creaters

- (NSDictionary *)wineEnvironment {
    return @{@"WINEPREFIX": [self.path path],
                   @"PATH": [[usrURL URLByAppendingPathComponent:@"bin"] path]};
}

- (NSFileHandle *)logFileHandle {
    // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
    NSString *logFilePath = [[self.path URLByAppendingPathComponent:@"wine.log"] path];
    int logFileDescriptor = open([logFilePath UTF8String],
                                 O_WRONLY | O_CREAT | O_APPEND,
                                 0644); // mode: -rw-r--r--
    
    if (logFileDescriptor < 0)
        [NSException raise:NSGenericException format:@"error opening file: %s", strerror(errno)];
    
    return [[NSFileHandle alloc] initWithFileDescriptor:logFileDescriptor closeOnDealloc:YES];
}

#pragma mark Messy stuff that has to exist

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

+ (void)initialize {
    if (self == [WinePrefix self]) {
        usrURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"usr"];
        
        if (ops == nil)
            ops = [NSOperationQueue new];
    }
}

@end

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";

NSString *const kWineServerExitStatus = @"kWineServerExitStatus";
