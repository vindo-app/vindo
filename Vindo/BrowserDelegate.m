//
//  BrowserDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 4/5/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserDelegate.h"
#import "Item.h"
#import "ItemBrowserCell.h"

@interface BrowserDelegate ()

@property IBOutlet NSTreeController *tree;
@property IBOutlet NSBrowser *browser;

@end

@implementation BrowserDelegate
//
//- (void)awakeFromNib {
//    //[self.browser bind:@"selectionIndexPaths"
//    //          toObject:self.tree
//    //       withKeyPath:@"selectionIndexPaths"
//    //           options:nil];
//}

- (Item *)rootItemForBrowser:(NSBrowser *)browser {
    return self.controller.rootItem;
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(Item *)item {
    return item.leaf;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(Item *)item {
    return item.children.count;
}

- (Item *)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(Item *)item {
    return item.children[index];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(Item *)item {
    return item.name;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(ItemBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
    Item *item = [sender itemAtRow:row inColumn:column];
    cell.stringValue = item.name;
    cell.image = item.image;
}

@end
