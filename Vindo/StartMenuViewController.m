//
//  StartMenuViewController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/14/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuViewController.h"
#import "StartMenuItem.h"
#import "StartMenuController.h"

@interface StartMenuViewController ()

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSView *buttonView;
@property (weak) IBOutlet NSSearchField *searchBox;
@property (strong) IBOutlet NSArrayController *arrayController;

@end

@implementation StartMenuViewController

- (instancetype)init {
    return [super initWithNibName:@"StartMenuViewController" bundle:nil];
}

- (void)loadView {
    [super loadView];
    
    self.view.postsFrameChangedNotifications = YES;
    
    [self performSelector:@selector(fixFirstResponder) withObject:nil afterDelay:0];
    
    self.searchBox.nextKeyView = self.collectionView;
    self.collectionView.nextKeyView = self.searchBox;
    
    [self.arrayController addObserver:self
                           forKeyPath:@"arrangedObjects"
                              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.numColumns"
                                                                 options:0
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.maxRows"
                                                                 options:0
                                                                 context:NULL];
    
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil]; // muahahaha
}

- (void)fixFirstResponder {
    self.searchBox.refusesFirstResponder = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([self.arrayController.content count] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MakeNoProgramsImportant" object:self];
    }
    
    NSUInteger numberOfItems = [self.arrayController.arrangedObjects count];
    
    NSUInteger columns = [[NSUserDefaults standardUserDefaults] integerForKey:@"numColumns"];
    NSUInteger maxRows = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxRows"];
    NSUInteger rows;
    if (numberOfItems % columns == 0)
        rows = numberOfItems / columns;
    else
        rows = (numberOfItems / columns) + 1;
    if (rows == 0)
        rows = 1;
    rows = MIN(rows, maxRows);
    
    [self setRows:rows columns:columns];
}

- (void)setRows:(NSUInteger)rows columns:(NSUInteger)columns {
    if (rows == _rows && columns == _columns)
        return;
    _rows = rows;
    _columns = columns;
    NSLog(@"resizing to %lu rows and %lu columns", (unsigned long)_rows, (unsigned long)_columns);
    [self resizeStuff];
    //[self performSelector:@selector(resizeStuff) withObject:nil afterDelay:0];
}

- (void)resizeStuff {
    CGFloat cellWidth = self.buttonView.frame.size.width;
    CGFloat cellHeight = self.buttonView.frame.size.height;
    CGFloat extraHeight = self.view.frame.size.height - self.scrollView.frame.size.height;
    
    NSSize collectionSize = (NSSize) {.width = _columns * cellWidth, .height = _rows * cellHeight};
    NSSize overallSize = (NSSize) {.width = collectionSize.width + 20, .height = collectionSize.height + extraHeight};
    [self.view setFrameSize:overallSize];
}

- (IBAction)buttonClicked:(id)sender {
    StartMenuItem *item = [[sender cell] representedObject];
    NSAssert([item isKindOfClass:[StartMenuItem class]], @"should be an item");
    [self moveButtonForStartMenuItem:item];
    
    [[NSWorkspace sharedWorkspace] openURL:item.bundle.bundleURL];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EliminatePopup" object:self];
}

- (void)moveButtonForStartMenuItem:(StartMenuItem *)item {
    StartMenu *menu = [StartMenuController sharedInstance].menu;
    NSUInteger itemIndex = [menu.items indexOfObject:item];
    if (itemIndex == NSNotFound) {
        NSLog(@"not found, tell someone");
        return;
    }
    
    // the formula
    double rank = itemIndex + 1 + ((double) item.subrank)/10;
    NSLog(@"rank = %lu (itemIndex) + 1 + %lu/10 (item.subrank) = %f", (unsigned long) itemIndex, (unsigned long) item.subrank, rank);
    rank = pow(rank, 0.85);
    NSLog(@"rank ^ 0.85 = %f", rank);
    item.subrank = (NSUInteger) ceil((rank - floor(rank)) * 10);
    NSLog(@"item.subrank = (%f - floor(%f)) (%f) * 10 = %lu", rank, rank, rank - floor(rank), item.subrank);
    NSUInteger newIndex = MAX(ceil(rank) - 2, 0);
    NSLog(@"newIndex = %ld", newIndex);
    
    [menu moveItemAtIndex:itemIndex toIndex:newIndex];
}

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"maxRows": @3, @"numColumns": @3}];
}

@end
