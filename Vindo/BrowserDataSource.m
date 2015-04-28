//
//  BrowserDataSource.m
//  Vindo
//
//  Created by Theodore Dubois on 4/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserDataSource.h"

@implementation BrowserDataSource

#pragma mark Outline data source

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(Item *)item {
    if (item == nil)
        item = self.root;
    return item.children.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(Item *)item {
    if (item == nil)
        item = self.root;
    return item.children[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(Item *)item {
    return !item.leaf;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(Item *)item {
    return item;
}

@end
