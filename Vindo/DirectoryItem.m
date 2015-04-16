//
//  DirectoryItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/9/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <CoreServices/CoreServices.h>
#import "DirectoryItem.h"

@interface DirectoryItem ()

@property FSEventStreamRef stream;

@end

@implementation DirectoryItem

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithURL:url]) {
        self.stream = FSEventStreamCreate(NULL,
                                          FSEventCallback,
                                          (__bridge void *)self,
                                          (__bridge CFArrayRef)@[self.url.path],
                                          kFSEventStreamEventIdSinceNow,
                                          1,
                                          kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagNoDefer);
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

- (void)handleFileSystemEventsWithPaths:(NSArray *)paths flags:(NSArray *)flags eventIds:(NSArray *)eventIds {
    NSLog(<#NSString *format, ...#>)
}

- (BOOL)isLeaf {
    return NO;
}

#pragma mark FSEvents stuff


static void FSEventCallback(ConstFSEventStreamRef streamRef,
                            void *clientCallBackInfo,
                            size_t numEvents,
                            void *eventPaths,
                            const FSEventStreamEventFlags eventFlags[],
                            const FSEventStreamEventId eventIds[]) {
    DirectoryItem *dirItem = (__bridge DirectoryItem *)clientCallBackInfo;
    [dirItem handleFileSystemEventsWithPaths:(__bridge NSArray *)eventPaths
                                       flags:(__bridge NSArray *)(CFArrayRef)eventFlags
                                    eventIds:(__bridge NSArray *)(CFArrayRef)eventIds];
}

@end
