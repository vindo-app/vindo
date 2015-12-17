//
//  SetupViewController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/14/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "SetupViewController.h"

@interface SetupViewController ()

@property IBOutlet NSProgressIndicator *spinningThing;

@end

@implementation SetupViewController

- (instancetype)init {
    return [super initWithNibName:@"SetupViewController" bundle:nil];
}

- (void)awakeFromNib {
    [self.spinningThing startAnimation:self];
}

@end
