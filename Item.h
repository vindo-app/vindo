//
//  Item.h
//  Vindo
//
//  Created by Theodore Dubois on 4/1/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Item : NSObject

@property NSString *name;
@property NSImage *image;
@property (getter=isLeaf) BOOL leaf;
@property NSArray *children;

@end
