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
    return [self wineTaskWithProgram:program arguments:arguments currentDirectory:NSHomeDirectory()];
}

- (NSTask *)wineTaskWithProgram:(NSString *)program arguments:(NSArray *)arguments currentDirectory:(NSString *)directory {
    NSTask *task = [NSTask new];
    task.launchPath = [[[usrURL URLByAppendingPathComponent:@"bin"]
                        URLByAppendingPathComponent:program]
                       path];
    task.arguments = arguments;
    task.environment = self.wineEnvironment;
    task.currentDirectoryPath = directory;
    task.standardInput = [NSFileHandle fileHandleWithNullDevice];
    task.standardOutput = [self logFileHandle];
    task.standardError = [self logFileHandle];

    return task;
}

- (NSDictionary *)wineEnvironment {
    return @{@"WINEPREFIX": [self.url path],
             @"WINEDEBUG": @"+seh,trace+appwizcpl",
             @"PATH": [[usrURL URLByAppendingPathComponent:@"bin"] path],
             @"DYLD_FALLBACK_LIBRARY_PATH": [[usrURL URLByAppendingPathComponent:@"lib"] path],
             @"THIS_IS_WHERE_THE_EXE_ICON_IS": [[NSBundle mainBundle] pathForResource:@"executable" ofType:@"icns"],
             };
}

- (NSFileHandle *)logFileHandle {
    // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
    NSString *logFilePath = [[self.url URLByAppendingPathComponent:@"wine.log"] path];
    int logFileDescriptor = open([logFilePath UTF8String],
                                 O_WRONLY | O_CREAT | O_APPEND,
                                 0644); // mode: -rw-r--r--

    if (logFileDescriptor < 0)
        [NSException raise:NSGenericException format:@"error opening file: %s", strerror(errno)];
    return [[NSFileHandle alloc] initWithFileDescriptor:logFileDescriptor closeOnDealloc:YES];
}

+ (void)initialize {
    usrURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"usr"];
}

@end
