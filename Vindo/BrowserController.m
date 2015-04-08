//
//  BrowserController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/29/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserController.h"
#import "FileItem.h"
#import "ItemBrowserCell.h"

static NSMutableArray *browsers;

@interface BrowserController ()

@property IBOutlet NSTabView *tabView;
@property IBOutlet NSBrowser *browser;

@end

@implementation BrowserController

- (id)init {
    if (self = [super initWithWindowNibName:@"Browser"]) {
        [browsers addObject:self]; // to have a strong reference
        self.window.delegate = self;
        self.rootItem = [[FileItem alloc] initWithFilePath:NSHomeDirectory()];
    }
    return self;
}

- (void)awakeFromNib {
    self.browser.cellClass = [ItemBrowserCell class];
}

- (IBAction)switchView:(NSSegmentedControl *)sender {
    [self.tabView selectTabViewItemAtIndex:sender.selectedSegment];
}

#pragma mark NSBrowserDelegate

- (Item *)rootItemForBrowser:(NSBrowser *)browser {
    return self.rootItem;
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
    return [NSNull null];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(ItemBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
    Item *item = [sender itemAtRow:row inColumn:column];
    cell.stringValue = item.name;
    cell.image = item.image;
}

#pragma mark Other Stuff

- (void)windowWillClose:(NSNotification *)notification {
    [browsers removeObject:self]; // get rid of the strong reference
}

+ (void)initialize {
    browsers = [NSMutableArray new];
}

@end
