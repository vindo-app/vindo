//
//  DirectoryItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/9/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "DirectoryItem.h"

@implementation DirectoryItem

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithURL:url]) {
        
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

- (BOOL)isLeaf {
    return NO;
}

@end
