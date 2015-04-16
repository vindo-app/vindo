//
//  Item.h
//  Vindo
//
//  Created by Theodore Dubois on 4/1/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Item : NSObject {
    @protected
    NSString *_name;
    NSImage *_image;
    BOOL _leaf;
    NSArray *_children;
}

@property (readonly) NSString *name;
@property (readonly) NSImage *image;
@property (readonly, getter=isLeaf) BOOL leaf;
@property (readonly) NSArray *children;

@end
