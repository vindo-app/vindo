//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WinePrefix.h"

static NSURL *usrURL;

#pragma mark Private Interfaces

@interface StartWineServerOperation : NSOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@property NSTask *server;

@end


@interface StopWineServerOperation : NSOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@end


@interface RunOperation : NSOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix program:(NSString *)program arguments:(NSArray *)arguments;

@property (readonly) WinePrefix *prefix;
@property (readonly) NSString *program;
@property (readonly) NSArray *arguments;

@end


@interface WinePrefix ()

@property StartWineServerOperation *startOp;
@property StopWineServerOperation *stopOp;

@end

#pragma mark Implementations

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

- (void)run:(NSString *)program {
    RunOperation *runOp = [[RunOperation alloc] initWithPrefix:self program:program arguments:@[]];
    [ops addOperation:runOp];
}

- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    RunOperation *runOp = [[RunOperation alloc] initWithPrefix:self program:program arguments:arguments];
    [ops addOperation:runOp];
}

- (NSTask *)taskWithProgram:(NSString *)program arguments:(NSArray *)arguments {
    NSTask *task = [NSTask new];
    task.launchPath = [[[usrURL URLByAppendingPathComponent:@"bin"]
                        URLByAppendingPathComponent:program]
                       path];
    task.arguments = arguments;
    task.environment = self.wineEnvironment;
    task.currentDirectoryPath = NSHomeDirectoryForUser(NSUserName());
    task.standardInput = [NSFileHandle fileHandleWithNullDevice];
    task.standardOutput = [self logFileHandle];
    task.standardError = [self logFileHandle];
    
    return task;
}

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

+ (void)initialize {
    if (self == [WinePrefix self]) {
        usrURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"usr"];
        
        if (ops == nil)
            ops = [NSOperationQueue new];
    }
}

@end

#pragma mark Operations

@implementation StartWineServerOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init])
        _prefix = prefix;
    return self;
}

- (void)main {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStartNotification object:self.prefix];
        
        if (self.isCancelled)
            return;
        
        NSTask *killExistingServer = [_prefix taskWithProgram:@"wineserver" arguments:@[@"-k"]]; // kill any existing wineserver
        [killExistingServer launch];
        [killExistingServer waitUntilExit];
        
        if (self.isCancelled)
            return;
        
        self.server = [_prefix taskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
        
        if (self.isCancelled)
            return;
        
        [center addObserver:self
                   selector:@selector(serverTaskStopped:)
                       name:NSTaskDidTerminateNotification
                     object:self.server];
        [self.server launch];
        
        // now that the server is launched, run wineboot to initialize the wine prefix (and kick the wineserver into action)
        NSTask *wineboot = [_prefix taskWithProgram:@"wine" arguments:@[@"wineboot", @"--init"]];
        [wineboot launch];
        [wineboot waitUntilExit];
        
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
    
    [center postNotificationName:WineServerDidStopNotification
                          object:self.prefix];
}

@end


@implementation StopWineServerOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)main {
    @try {
        if (_prefix.startOp.isExecuting) {
            [_prefix.startOp cancel];
            [_prefix.startOp waitUntilFinished];
        }
        
        // first end the session with wineboot
        NSTask *endSession = [_prefix taskWithProgram:@"wine" arguments:@[@"wineboot", @"--end-session"]];
        [endSession launch];
        [endSession waitUntilExit];
        
        NSTask *server = _prefix.startOp.server;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center postNotificationName:WineServerWillStopNotification object:self.prefix];
        [server interrupt];
        [server waitUntilExit];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end


@implementation RunOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix program:(NSString *)program arguments:(NSArray *)arguments {
    if (self = [super init]) {
        _prefix = prefix;
        _program = program;
        _arguments = arguments;
    }
    return self;
}

- (void)main {
    @try {
        NSTask *program = [_prefix taskWithProgram:@"wine" arguments:[@[_program] arrayByAddingObjectsFromArray:_arguments]];
        [program launch];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end

#pragma mark Notification Constants

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";

NSString *const kWineServerExitStatus = @"kWineServerExitStatus";
