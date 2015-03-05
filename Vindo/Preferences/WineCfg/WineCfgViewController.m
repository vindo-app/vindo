//
//  WineCfgViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineCfgViewController.h"

@implementation WineCfgViewController

- (IBAction)runWinecfg:(id)sender {
    AppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
    [appDelegate doNothing:sender];
}

- (NSString *)identifier {
    return NSStringFromClass(self.class);
}

- (NSString *)toolbarItemLabel {
    return @"Wine Control Panel";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:@"winecfg"];
}

@end
