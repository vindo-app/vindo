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
#import "World+StartMenu.h"
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
    
    if (flags & kFSEventStreamEventFlagItemCreated) {
        [self addItemAtURL:event.URL];
    } else if (flags & kFSEventStreamEventFlagItemRemoved) {
        [self removeItemAtURL:event.URL];
    }
}

- (void)addItemAtURL:(NSURL *)url {
    NSString *nativeIdentifier = [self nativeIdentifierForURL:url];
    
    [self willChange:NSKeyValueChangeInsertion
     valuesAtIndexes:[NSIndexSet indexSetWithIndex:self.mutableItems.count]
              forKey:@"items"];
    [self.mutableItems addObject:[[StartMenuItem alloc] initWithNativeIdentifier:nativeIdentifier inWorld:self.world]];
    [self didChange:NSKeyValueChangeInsertion
    valuesAtIndexes:[NSIndexSet indexSetWithIndex:self.mutableItems.count]
             forKey:@"items"];
}

- (void)removeItemAtURL:(NSURL *)url {
    if (![url.path hasSuffix:@".plist"])
        return;
    
    NSString *nativeIdentifier = [self nativeIdentifierForURL:url];
    
    int i;
    for (i = 0; i < self.mutableItems.count; i++) {
        if ([[self.mutableItems[i] nativeIdentifier] isEqualToString:nativeIdentifier]) {
            break;
        }
    }
    StartMenuItem *itemToRemove = self.mutableItems[i];
    
    if (itemToRemove) {
        [self willChange:NSKeyValueChangeRemoval
         valuesAtIndexes:[NSIndexSet indexSetWithIndex:i]
                  forKey:@"items"];
        [self.mutableItems removeObject:itemToRemove];
        [self didChange:NSKeyValueChangeRemoval
        valuesAtIndexes:[NSIndexSet indexSetWithIndex:i]
                 forKey:@"items"];
    }
}

- (void)initializeItems {
    NSString *defaultsKey = [NSString stringWithFormat:@"startMenuItems_%@", self.world.name];
    NSArray *startMenuNativeIdentifiers = [[NSUserDefaults standardUserDefaults] arrayForKey:defaultsKey];
    
    NSLog(@"sm: loading items %@", startMenuNativeIdentifiers);
    NSMutableArray *newItems = [NSMutableArray new];
    for (NSString *nativeIdentifier in startMenuNativeIdentifiers) {
        [newItems addObject:[[StartMenuItem alloc] initWithNativeIdentifier:nativeIdentifier inWorld:self.world]];
    }
    
    self.mutableItems = newItems;
}

- (NSString *)nativeIdentifierForURL:(NSURL *)url {
    return url.path.stringByDeletingPathExtension.lastPathComponent;
}

- (NSArray *)items {
    return [_mutableItems copy];
}

- (void)dealloc {
    self.events.delegate = nil;
}

@end
