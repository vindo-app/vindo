//
//  BootCycleController.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "BootCycleController.h"
#import "WorldsController.h"

@implementation BootCycleController

- (void)awakeFromNib {
    [[WorldsController sharedController] addObserver:self
                                          forKeyPath:@"selectedObjects"
                                             options:NSKeyValueObservingOptionInitial
                                             context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [[WorldsController sharedController].selectedWorld start];
}

@end
