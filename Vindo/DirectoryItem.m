//
//  DirectoryItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/9/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "DirectoryItem.h"

@implementation DirectoryItem

- (instancetype)initWithFilePath:(NSString *)path {
    if (self = [super initWithFilePath:path]) {
        
    }
    return self;
}

- (void)refreshChildren {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *children = [NSMutableArray new];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:self.path];
    for (NSString *relativePath in enumerator) {
        NSString *path = [self.path stringByAppendingPathComponent:relativePath]; // paths returned by enumerator are relative
        Item *item = [[FileItem alloc] initWithFilePath:path];
        [children addObject:item];
    }
    _children = children;
}

- (NSArray *)children {
    if (_children == nil)
        [self refreshChildren];
    return _children;
}

- (BOOL)isLeaf {
    return YES;
}

@end
