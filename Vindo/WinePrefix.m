//
//  WinePrefix.m
//  Vindo
//
//  Created by Theodore Dubois on 6/6/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "World.h"

static NSURL *usrURL;
static NSMapTable *prefixes;

@implementation World (WinePrefix)

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

- (NSDictionary *)wineEnvironment {
    return @{@"WINEPREFIX": [self.url path],
             @"PATH": [[usrURL URLByAppendingPathComponent:@"bin"] path],
             @"DYLD_FALLBACK_LIBRARY_PATH": [[usrURL URLByAppendingPathComponent:@"lib"] path],
             @"THIS_IS_WHERE_THE_EXE_ICON_IS": [[NSBundle mainBundle] pathForResource:@"executable" ofType:@"icns"],
             };
}

- (NSFileHandle *)logFileHandle {
    if (_logFileHandle == nil) {
        // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
        NSString *logFilePath = [[self.url URLByAppendingPathComponent:@"wine.log"] path];
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
    usrURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"usr"];
}

@end
