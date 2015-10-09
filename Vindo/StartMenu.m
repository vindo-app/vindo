//
//  StartMenu.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenu.h"
#import "StartMenuItem.h"
#import "WorldsController.h"
#import "World.h"
#import "WinePrefix.h"
#import <CDEvents/CDEvents.h>
#import <CoreServices/CoreServices.h>

@interface StartMenu ()

@property NSMutableArray *mutableItems;
@property NSURL *programsFolder;
@property CDEvents *events;

@end

@implementation StartMenu

- (instancetype)initWithWorld:(World *)world {
    if (self = [super init]) {
        NSFileManager *manager = [NSFileManager defaultManager];
        
        self.mutableItems = [NSMutableArray new];
        
        NSURL *worldFolder = world.prefix.prefixURL;
        self.programsFolder = [worldFolder URLByAppendingPathComponent:@"menu/programs"];
        [manager createDirectoryAtURL:self.programsFolder
          withIntermediateDirectories:YES
                           attributes:nil
                                error:NULL];

        //[self URLWatcher:nil eventOccurred:nil]; // trigger a refresh
        
        self.events = [[CDEvents alloc] initWithURLs:@[self.programsFolder]
                                            delegate:self
                                           onRunLoop:[NSRunLoop currentRunLoop]
                                sinceEventIdentifier:kFSEventStreamEventIdSinceNow
                                notificationLantency:2
                             ignoreEventsFromSubDirs:NO
                                         excludeURLs:nil
                                 streamCreationFlags:kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot];
    }
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event {
    NSLog(@"event apparantly happened");
    // just redo everything for now
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *startMenuFiles = [manager contentsOfDirectoryAtURL:_programsFolder
                                     includingPropertiesForKeys:@[NSURLNameKey]
                                                        options:0
                                                          error:NULL];
    
    NSMutableArray *newItems = [NSMutableArray new];
    for (NSURL *startMenuFile in startMenuFiles) {
        if (![[startMenuFile path] hasSuffix:@".plist"])
            continue;
        
        [newItems addObject:[[StartMenuItem alloc] initFromFile:startMenuFile]];
    }
    self.mutableItems = newItems;
}

- (NSArray *)items {
    return [_mutableItems copy];
}

- (void)dealloc {
    self.events.delegate = nil;
}

@end
