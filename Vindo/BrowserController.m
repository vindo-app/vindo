//
//  BrowserController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/29/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserController.h"
#import "FileItem.h"

@interface BrowserController ()

@property IBOutlet NSOutlineView *sidebar;
@property IBOutlet NSTabView* tabView;

@end

@implementation BrowserController

- (id)init {
    if (self = [super initWithWindowNibName:@"Browser"]) {
        self.rootItem = [[FileItem alloc] initWithFilePath:NSHomeDirectory()];
    }
    return self;
}

- (IBAction)switchView:(NSSegmentedControl *)sender {
    [self.tabView selectTabViewItemAtIndex:sender.selectedSegment];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(NSBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
    Item *item = [sender itemAtRow:row inColumn:column];
    cell.image = item.image;
    cell.stringValue = item.name;
    
}

@end
