//
//  WinePrefix.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WinePrefix.h"
#import "WineServer.h"

static NSURL *usrURL;
static NSMapTable *prefixes;

@interface WinePrefix ()

@property (nonatomic) NSFileHandle *logFileHandle;

@end

@implementation WinePrefix

- (instancetype)initWithPrefixURL:(NSURL *)prefixURL {
    if ([prefixes objectForKey:prefixURL] != nil)
        return [prefixes objectForKey:prefixURL];

    if (self = [super init]) {
        _prefixURL = prefixURL;
        _server = [[WineServer alloc] initWithPrefix:self];
    }

    [prefixes setObject:self forKey:prefixURL];
    return self;
}

- (NSTask *)wineTaskWithProgram:(NSString *)program
                  arguments:(NSArray *)arguments {
    NSTask *task = [NSTask new];
    task.launchPath = [[[usrURL URLByAppendingPathComponent:@"bin"]
                        URLByAppendingPathComponent:program]
                       path];
    task.arguments = arguments;
    task.environment = self.wineEnvironment;
    task.currentDirectoryPath = NSHomeDirectory();
    task.standardInput = [NSFileHandle fileHandleWithNullDevice];
    task.standardOutput = [self logFileHandle];
    task.standardError = [self logFileHandle];

    return task;
}

- (void)startServer {
    [self.server start];
}

- (void)stopServer {
    [self.server stop];
}

- (void)startServerAndWait {
    [self.server startAndWait];
}

- (void)stopServerAndWait {
    [self.server stopAndWait];
}

- (NSDictionary *)wineEnvironment {
    return @{@"WINEPREFIX": [self.prefixURL path],
             @"PATH": [[usrURL URLByAppendingPathComponent:@"bin"] path],
             @"DYLD_FALLBACK_LIBRARY_PATH": [[usrURL URLByAppendingPathComponent:@"lib"] path]
             };
}

- (NSFileHandle *)logFileHandle {
    if (_logFileHandle == nil) {
        // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
        NSString *logFilePath = [[self.prefixURL URLByAppendingPathComponent:@"wine.log"] path];
        int logFileDescriptor = open([logFilePath UTF8String],
                                     O_WRONLY | O_CREAT | O_APPEND,
                                     0644); // mode: -rw-r--r--

        if (logFileDescriptor < 0)
            [NSException raise:NSGenericException format:@"error opening file: %s", strerror(errno)];
        _logFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:logFileDescriptor closeOnDealloc:YES];
    }
    return _logFileHandle;
}

+ (void)initialize {
    if (self == [WinePrefix class]) {
        usrURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"usr"];
        prefixes = [NSMapTable strongToWeakObjectsMapTable];
    }
}

@end
