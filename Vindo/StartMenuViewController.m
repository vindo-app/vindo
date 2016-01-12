//
//  StartMenuViewController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/14/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuViewController.h"

@interface StartMenuViewController ()

@property (weak) IBOutlet NSCollectionView *collectionView;

@end

@implementation StartMenuViewController

- (instancetype)init {
    return [super initWithNibName:@"StartMenuViewController" bundle:nil];
}

- (void)loadView {
    [super loadView];
    
    [self setRows:2 columns:3];
}

- (void)setRows:(NSUInteger)rows columns:(NSUInteger)columns {
    _rows = rows;
    _columns = columns;
    [self resizeStuff];
}

#define CELL_WIDTH 72
#define CELL_HEIGHT 72

- (void)resizeStuff {
    NSSize collectionSize = (NSSize) {.width = _columns * CELL_WIDTH, .height = _rows * CELL_HEIGHT};
    self.collectionView.frame = (NSRect) {.origin = NSMakePoint(10, 10), .size = collectionSize};
    
    NSSize overallSize = (NSSize) {.width = collectionSize.width + 20, .height = collectionSize.height + 20};
    self.view.frame = (NSRect) {.origin = self.view.frame.origin, .size = overallSize};
}

@end
