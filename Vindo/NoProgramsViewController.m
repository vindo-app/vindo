//
//  NoProgramsViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 1/17/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "NoProgramsViewController.h"

@interface NoProgramsViewController ()

@property (strong) IBOutlet NSArrayController *arrayController;

@end

@implementation NoProgramsViewController

- (void)awakeFromNib {
    [self.arrayController addObserver:self
                           forKeyPath:@"arrangedObjects"
                              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                              context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSUInteger numberOfItems = [self.arrayController.arrangedObjects count];
    if (numberOfItems != 0) {
        NSLog(@"made default important");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MakeDefaultImportant"
                                                            object:self];
    }
}

@end
