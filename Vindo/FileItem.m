//
//  FileItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/2/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "FileItem.h"
#import "DirectoryItem.h"

@implementation FileItem

- (instancetype)initWithFilePath:(NSString *)path {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
        if (isDir && ![self isKindOfClass:[DirectoryItem class]])
            return [[DirectoryItem alloc] initWithFilePath:path];
    
    if (self = [super init]) {
        _path = path;
        [self refresh];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)refresh {
    _name = [_path lastPathComponent];
    _image = [[NSWorkspace sharedWorkspace] iconForFile:_path];
}

- (BOOL)isLeaf {
    return NO;
}

@end
