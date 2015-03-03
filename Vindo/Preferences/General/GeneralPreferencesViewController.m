//
//  GeneralPreferencesViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/2/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

@implementation GeneralPreferencesViewController

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:NO], @"startAtLogin",
                                       @"Windows 7", @"windowsVersion",
                                    nil]];
    }
    return self;
}

- (NSString *)identifier {
    return NSStringFromClass(self.class);
}

- (NSString *)toolbarItemLabel {
    return @"General";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
