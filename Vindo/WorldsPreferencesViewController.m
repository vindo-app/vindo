//
//  WorldsPreferencesViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsPreferencesViewController.h"

@interface WorldsPreferencesViewController ()

@property IBOutlet NSTableView *table;

@end

@implementation WorldsPreferencesViewController

- (instancetype)init {
    return [super initWithNibName:@"WorldsPreferences" bundle:nil];
}

- (NSString *)toolbarItemLabel {
    return @"Worlds";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNameNetwork];
}

- (NSString *)identifier {
    return self.className;
}

-(void)viewDidAppear {
    
}

@end
