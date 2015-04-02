//
//  FileItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/2/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "FileItem.h"

static NSFileManager *fm;
static NSWorkspace *ws;

@implementation FileItem

- (id)initWithFilePath:(NSString *)path {
    if (self = [super init]) {
        _path = path;
    }
    return self;
}

- (NSString *)name {
    return [self.path lastPathComponent];
}

- (NSImage *)image {
    return [ws iconForFile:self.path];
}

- (BOOL)isLeaf {
    BOOL isDir;
    [fm fileExistsAtPath:self.path isDirectory:&isDir];
    return isDir;
}

- (NSArray *)children {
    return @[];
}

+ (void)initialize {
    fm = [NSFileManager defaultManager];
    ws = [NSWorkspace sharedWorkspace];
}

@end
