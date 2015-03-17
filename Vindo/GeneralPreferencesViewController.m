//
//  GeneralPreferencesViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/2/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

@implementation GeneralPreferencesViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"GeneralPreferences" bundle:nil]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{@"startAtLogin":   @NO,
                                     @"windowsVersion": @"Windows 7"}];
    }
    return self;
}

- (NSString *)identifier {
    return self.className;
}

- (NSString *)toolbarItemLabel {
    return @"General";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
