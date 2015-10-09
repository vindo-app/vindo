//
//  StartMenuItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuItem.h"
#import "World.h"
#import "WinePrefix.h"
#import "WorldsController.h"

@implementation StartMenuItem

- (instancetype)initFromFile:(NSURL *)file {
    if (self = [super init]) {
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfURL:file options:0 error:&error];
        NSDictionary *itemPlist;
        if (fileData) {
            itemPlist = [NSPropertyListSerialization propertyListWithData:fileData
                                                                  options:NSPropertyListImmutable
                                                                   format:NULL
                                                                    error:&error];
        }
        if (error) {
            NSLog(@"%@", error);
            return nil;
        }
        
        _name = itemPlist[@"Name"];
        _path = itemPlist[@"Path"];
        _args = itemPlist[@"Arguments"];
    }
    return self;
}

@end
