//
//  GeneralPreferencesViewController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/23/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

@interface GeneralPreferencesViewController ()

@end

@implementation GeneralPreferencesViewController

- (NSString *)identifier {
    return [self className];
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel {
    return @"General";
}

@end
