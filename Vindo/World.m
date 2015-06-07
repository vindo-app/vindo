//
//  World.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"

@implementation World

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

- (NSURL *)prefixPath:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [[[manager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Vindo"];
    return [applicationSupport URLByAppendingPathComponent:name];
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
    return [[World alloc] initWithName:
            [[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:NSPasteboardTypeString]];
}


//#pragma mark Task Creaters
//
//- (NSTask *)taskWithWindowsProgram:(NSString *)program arguments:(NSArray *)arguments {
//    NSString *currentDirectory;
//    if ([program rangeOfString:@"/"].location == NSNotFound) // quick and dirty
//        currentDirectory = NSHomeDirectory();
//    else
//        currentDirectory = [program stringByDeletingLastPathComponent];
//    
//    return [self taskWithProgram:@"wine"
//                       arguments:[@[program] arrayByAddingObjectsFromArray:arguments]
//                currentDirectory:currentDirectory];
//}
//
//- (NSTask *)taskWithProgram:(NSString *)program arguments:(NSArray *)arguments {
//    return [self taskWithProgram:program
//                       arguments:arguments
//                currentDirectory:NSHomeDirectory()];
//}
//
//- (NSTask *)taskWithProgram:(NSString *)program
//                  arguments:(NSArray *)arguments
//           currentDirectory:(NSString *)currentDirectory {
//    NSTask *task = [NSTask new];
//    task.launchPath = [[[usrURL URLByAppendingPathComponent:@"bin"]
//                        URLByAppendingPathComponent:program]
//                       path];
//    task.arguments = arguments;
//    task.environment = self.wineEnvironment;
//    task.currentDirectoryPath = currentDirectory;
//    task.standardInput = [NSFileHandle fileHandleWithNullDevice];
//    task.standardOutput = [self logFileHandle];
//    task.standardError = [self logFileHandle];
//    
//    return task;
//}
//
//#pragma mark Utilities for Task Creaters
//
//- (NSDictionary *)wineEnvironment {
//    return @{@"WINEPREFIX": [self.path path],
//             @"PATH": [[usrURL URLByAppendingPathComponent:@"bin"] path],
//             @"DYLD_FALLBACK_LIBRARY_PATH": [[usrURL URLByAppendingPathComponent:@"lib"] path]
//             };
//}
//
//- (NSFileHandle *)logFileHandle {
//    // we have to use the unix functions for opening files because NSFileHandle doesn't do appending
//    NSString *logFilePath = [[self.path URLByAppendingPathComponent:@"wine.log"] path];
//    int logFileDescriptor = open([logFilePath UTF8String],
//                                 O_WRONLY | O_CREAT | O_APPEND,
//                                 0644); // mode: -rw-r--r--
//    
//    if (logFileDescriptor < 0)
//        [NSException raise:NSGenericException format:@"error opening file: %s", strerror(errno)];
//    
//    return [[NSFileHandle alloc] initWithFileDescriptor:logFileDescriptor closeOnDealloc:YES];
//}
//
//#pragma mark Messy stuff that has to exist
//
//- (void)dealloc {
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center removeObserver:self];
//}
//
//+ (void)initialize {
//    if (self == [World self]) {
//        worldsDictionary = [NSMutableDictionary new];
//        usrURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"usr"];
//    }
//}
//
@end

NSString *const WorldPasteboardType = @"org.vindo.world";

