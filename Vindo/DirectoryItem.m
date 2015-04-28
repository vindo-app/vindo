//
//  DirectoryItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/9/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <CDEvents.h>
#import <CDEventsDelegate.h>
#import "DirectoryItem.h"

@interface DirectoryItem () <CDEventsDelegate>

@property CDEvents *stream;

@end

@implementation DirectoryItem

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithURL:url]) {
        self.stream = [[CDEvents alloc] initWithURLs:@[url]
                                            delegate:self
                                           onRunLoop:[NSRunLoop mainRunLoop]
                                sinceEventIdentifier:kCDEventsSinceEventNow
                                notificationLantency:1
                             ignoreEventsFromSubDirs:YES
                                         excludeURLs:nil
                                 streamCreationFlags:kCDEventsDefaultEventStreamFlags];
    }
    return self;
}

- (void)refreshChildren {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *children = [NSMutableArray new];
    BOOL (^errorHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error) {
        [NSApp presentError:error];
        NSLog(@"[DirectoryItem refreshChildren]: directory enumeration for %@ failed with error: %@", url, error);
        return YES;
    };
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:self.url
                                 includingPropertiesForKeys:nil
                                                    options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                               errorHandler:errorHandler];
    for (NSURL *url in enumerator) {
        [children addObject:[[FileItem alloc] initWithURL:url]];
    }
    _children = children;
}

- (NSArray *)children {
    if (_children == nil)
        [self refreshChildren];
    return _children;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event {
    NSLog(@"%@", event);
    [self willChangeValueForKey:@"children"];
    _children = nil; // will refresh
    [self didChangeValueForKey:@"children"];
}

- (BOOL)isLeaf {
    return NO;
}

#pragma mark FSEvents stuff

@end
