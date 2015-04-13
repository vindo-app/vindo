//
//  BrowserDelegate.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/9/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserDelegate.h"
#import "ItemBrowserCell.h"

@interface BrowserDelegate ()

@property IBOutlet BrowserController *controller;
@property IBOutlet NSBrowser *browser;
@property IBOutlet NSTreeController *tree;

@end

@implementation BrowserDelegate

- (void)awakeFromNib {
    [self.tree addObserver:self
                forKeyPath:@"arrangedObjects"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
    [self.tree addObserver:self
                forKeyPath:@"selectionIndexPaths"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
}

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

- (void)browser:(NSBrowser *)sender willDisplayCell:(ItemBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
    Item *item = [sender itemAtRow:row inColumn:column];
    cell.stringValue = item.name;
    cell.image = item.image;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(Item *)item {
    return @"";
}

// this is the browser's action
- (IBAction)selectItem:(id)sender {
    self.tree.selectionIndexPaths = self.browser.selectionIndexPaths;
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"arrangedObjects"]) {
        [self.browser reloadColumn:0];
    } else if ([keyPath isEqualToString:@"selectionIndexPaths"]) {
        // Admittedly ugly workaround for the fact that Apple deprected the *useful* method isLoaded.
        // If we try to set the selectionIndexPaths when the browser isn't loaded, it will throw an
        // OOB exception when it tries to access column 0 and there are no columns. So catch it and
        // ignore it. If it's not OOB, rethrow it.
        @try {
            //[self.browser reloadColumn:0];
            self.browser.selectionIndexPaths = self.tree.selectionIndexPaths;
        }
        @catch (NSException *exception) {
#ifdef DEBUG
            NSLog(@"BrowserDelegate setting sel-idx-paths: %@", exception);
#endif
            if (![exception.name isEqualToString:NSRangeException])
                [exception raise];
        }
    }
}

@end
