//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "WineServerOperations.h"
#import "NSOperationQueue+DefaultQueue.h"

static NSMutableDictionary *worldsDictionary;
static NSURL *usrURL;

@interface World ()

@property WineServerState state;

@end

@implementation World

+ (World *)worldNamed:(NSString *)name {
    if (worldsDictionary[name] == nil)
        worldsDictionary[name] = [[self alloc] initWithName:name];
    return worldsDictionary[name];
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
        
        _path = [self prefixPath:name];
        
        self.state = WineServerStopped;
        
        // make sure to stop the server when the app is about to terminate
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(stopServerFromNotification:)
                       name:NSApplicationWillTerminateNotification
                     object:NSApp];
    }
    return self;
}

+ (World *)defaultWorld {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *worlds = [defaults arrayForKey:@"worlds"];
    NSUInteger defaultWorldIndex = [defaults integerForKey:@"defaultWorldIndex"];
    return [self worldNamed:worlds[defaultWorldIndex]];
}

+ (void)deleteWorldNamed:(NSString *)name {
    [worldsDictionary removeObjectForKey:name];
}

- (NSURL *)prefixPath:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [[[manager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Vindo"];
    return [applicationSupport URLByAppendingPathComponent:name];
}

#pragma mark Fun Stuff

- (void)start {
    if (self.state == WineServerStopped || self.state == WineServerStopping) {
        [[NSOperationQueue defaultQueue] addOperation:
         [[StartWineServerOperation alloc] initWithWorld:self]];
    }
}

- (void)startAndWait {
    if (self.state == WineServerStopped || self.state == WineServerStopping) {
        NSOperation *startOp = [[StartWineServerOperation alloc] initWithWorld:self];
        [[NSOperationQueue defaultQueue] addOperation:startOp];
        [startOp waitUntilFinished];
    }
}

- (void)reboot {
    [self run:@"wineboot" withArguments:@[@"--restart"]];
}

- (void)stop {
    if (self.state == WineServerRunning || self.state == WineServerStarting) {
        [[NSOperationQueue defaultQueue] addOperation:
         [[StopWineServerOperation alloc] initWithWorld:self]];
    }
}

- (void)stopAndWait {
    if (self.state == WineServerStopped || self.state == WineServerStarting) {
        NSOperation *stopOp = [[StopWineServerOperation alloc] initWithWorld:self];
        [[NSOperationQueue defaultQueue] addOperation:stopOp];
        [stopOp waitUntilFinished];
    }
}

- (void)stopServerFromNotification:(NSNotification *)notification {
    [self stopAndWait];
}

- (void)run:(NSString *)program {
    RunOperation *runOp = [[RunOperation alloc] initWithWorld:self program:program arguments:@[]];
    [[NSOperationQueue defaultQueue] addOperation:runOp];
}

- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    RunOperation *runOp = [[RunOperation alloc] initWithWorld:self program:program arguments:arguments];
    [[NSOperationQueue defaultQueue] addOperation:runOp];
}

#pragma mark Pasteboard Stuff

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[WorldPasteboardType];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    return [self.name pasteboardPropertyListForType:NSPasteboardTypeString];
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[WorldPasteboardType];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsData;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    return [World worldNamed:[[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:NSPasteboardTypeString]];
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
             @"PATH": [[usrURL URLByAppendingPathComponent:@"bin"] path],
             @"DYLD_FALLBACK_LIBRARY_PATH": [[usrURL URLByAppendingPathComponent:@"lib"] path]
             };
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
    if (self == [World self]) {
        worldsDictionary = [NSMutableDictionary new];
        usrURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"usr"];
    }
}

@end

NSString *const WorldPasteboardType = @"org.vindo.world";

NSString *const WineServerWillStartNotification = @"WineServerWillStartNotification";
NSString *const WineServerDidStartNotification = @"WineServerDidStartNotification";
NSString *const WineServerWillStopNotification = @"WineServerWillStopNotification";
NSString *const WineServerDidStopNotification = @"WineServerDidStopNotification";
NSString *const WineServerDidCrashNotification = @"WineServerDidCrashNotification";