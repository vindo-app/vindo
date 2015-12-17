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

@property World *world;

@end

@implementation StartMenu

- (instancetype)initWithWorld:(World *)world {
    if (self = [super init]) {
        self.world = world;
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        self.mutableItems = [NSMutableArray new];
        
        self.programsFolder = self.world.programsFolder;
        [manager createDirectoryAtURL:self.programsFolder
          withIntermediateDirectories:YES
                           attributes:nil
                                error:NULL];

        [self URLWatcher:nil eventOccurred:nil]; // trigger a refresh
        
        self.events = [[CDEvents alloc] initWithURLs:@[self.programsFolder]
                                            delegate:self
                                           onRunLoop:[NSRunLoop mainRunLoop]
                                sinceEventIdentifier:kFSEventStreamEventIdSinceNow
                                notificationLantency:1
                             ignoreEventsFromSubDirs:NO
                                         excludeURLs:nil
                                 streamCreationFlags:kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot];
    }
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event {
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

        NSString *nativeIdentifier = startMenuFile.path.stringByDeletingPathExtension.lastPathComponent;
        
        [newItems addObject:[[StartMenuItem alloc] initWithNativeIdentifier:nativeIdentifier inWorld:self.world]];
    }
    [self willChangeValueForKey:@"items"];
    self.mutableItems = newItems;
    [self didChangeValueForKey:@"items"];
}

- (NSArray *)items {
    return [_mutableItems copy];
}

- (void)dealloc {
    self.events.delegate = nil;
}

@end
