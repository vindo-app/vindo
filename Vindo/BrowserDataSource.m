//
//  BrowserDataSource.m
//  Vindo
//
//  Created by Theodore Dubois on 4/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserDataSource.h"
#import "ItemBrowserCell.h"

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

#pragma mark Browser delegate

- (Item *)rootItemForBrowser:(NSBrowser *)browser {
    return self.root;
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
    cell.image = item.image;
    cell.stringValue = item.name;
}

- (CGFloat)browser:(NSBrowser *)browser
  shouldSizeColumn:(NSInteger)columnIndex
     forUserResize:(BOOL)forUserResize
           toWidth:(CGFloat)suggestedWidth {
    return 204; // like the finder
}

- (BOOL)browser:(NSBrowser *)browser shouldShowCellExpansionForRow:(NSInteger)row column:(NSInteger)column {
    return YES;
}

@end
