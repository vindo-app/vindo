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
#import "NSUserDefaults+KeyPaths.h"
#import "World+StartMenu.h"
#import "NSURL+Relativize.h"
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
        self.world = world;
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        self.mutableItems = [NSMutableArray new];
        
        self.programsFolder = self.world.programsFolder;
        [manager createDirectoryAtURL:self.programsFolder
          withIntermediateDirectories:YES
                           attributes:nil
                                error:NULL];

        [self initializeItems];
        
        self.events = [[CDEvents alloc] initWithURLs:@[self.programsFolder]
                                            delegate:self
                                           onRunLoop:[NSRunLoop mainRunLoop]
                                sinceEventIdentifier:kFSEventStreamEventIdSinceNow
                                notificationLantency:1
                             ignoreEventsFromSubDirs:NO
                                         excludeURLs:nil
                                 streamCreationFlags:kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMenu:) name:@"PopoverJustOpened" object:nil];
    }
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event {
    [self performSelectorOnMainThread:@selector(dealWithEvent:)
                           withObject:event
                        waitUntilDone:NO];
}

- (void)dealWithEvent:(CDEvent *)event {
    FSEventStreamEventFlags flags = event.flags;
    if (![event.URL.path hasSuffix:@".plist"])
        return;

    if (flags & kFSEventStreamEventFlagItemRemoved) {
        [self removeItemAtURL:event.URL];
    } else if (flags & kFSEventStreamEventFlagItemCreated) {
        [self addItemAtURL:event.URL];
    }
    [self.world run:@"winemenubuilder" withArguments:@[@"-a"]];
}

- (void)addItemAtURL:(NSURL *)url {
    NSString *itemPath = [self itemPathForURL:url];
    
    [self willChange:NSKeyValueChangeInsertion
     valuesAtIndexes:[NSIndexSet indexSetWithIndex:self.mutableItems.count]
              forKey:@"items"];
    [self.mutableItems addObject:[[StartMenuItem alloc] initWithItemPath:itemPath inWorld:self.world]];
    [self didChange:NSKeyValueChangeInsertion
    valuesAtIndexes:[NSIndexSet indexSetWithIndex:self.mutableItems.count]
             forKey:@"items"];
}

- (void)removeItemAtURL:(NSURL *)url {
    if (![url.path hasSuffix:@".plist"])
        return;
    
    NSString *itemPath = [self itemPathForURL:url];
    
    int i;
    for (i = 0; i < self.mutableItems.count; i++)
        if ([[self.mutableItems[i] itemPath] isEqualToString:itemPath])
            break;
    StartMenuItem *itemToRemove = self.mutableItems[i];
    
    if (itemToRemove) {
        [itemToRemove.bundle remove];
        [self willChange:NSKeyValueChangeRemoval
         valuesAtIndexes:[NSIndexSet indexSetWithIndex:i]
                  forKey:@"items"];
        [self.mutableItems removeObject:itemToRemove];
        [self didChange:NSKeyValueChangeRemoval
        valuesAtIndexes:[NSIndexSet indexSetWithIndex:i]
                 forKey:@"items"];
    }
}


- (void)moveItemAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    if (newIndex == index)
        return;
    
    [self willChangeValueForKey:@"items"];
    StartMenuItem *item = self.mutableItems[index];
    [self.mutableItems removeObjectAtIndex:index];
    [self.mutableItems insertObject:item atIndex:newIndex];
    [self didChangeValueForKey:@"items"];
}

- (void)initializeItems {
    NSMutableArray *newItems = [NSMutableArray new];

    NSArray *defaultsItems = [[NSUserDefaults standardUserDefaults] valueForKeyPathArray:@[@"startMenuItems", self.world.name]];
    
    NSMutableArray *filesystemItems = [NSMutableArray new];
    for (NSString *filesystemItem in [[NSFileManager defaultManager] enumeratorAtPath:self.programsFolder.path]) {
        if ([filesystemItem hasSuffix:@".plist"])
            [filesystemItems addObject:filesystemItem.stringByDeletingPathExtension];
    }
    
    NSMutableArray *addedItems = [filesystemItems mutableCopy];
    [addedItems removeObjectsInArray:defaultsItems];
    for (NSString *addedItem in addedItems) {
        [newItems addObject:[[StartMenuItem alloc] initWithItemPath:addedItem inWorld:self.world]];
    }
    for (NSString *item in defaultsItems) {
        if ([filesystemItems containsObject:item])
            [newItems addObject:[[StartMenuItem alloc] initWithItemPath:item inWorld:self.world]];
    }
    
    self.mutableItems = newItems;
}

- (void)refreshMenu:(NSNotification *)notification {
    NSTask *task = [self.world wineTaskWithProgram:@"wine" arguments:@[@"winemenubuilder", @"-r"]];
    [task launch];
}

- (NSString *)itemPathForURL:(NSURL *)url {
    return [url pathRelativeToURL:self.programsFolder].stringByDeletingPathExtension;
}

- (NSArray *)items {
    return [_mutableItems copy];
}

- (void)dealloc {
    self.events.delegate = nil;
}

@end
