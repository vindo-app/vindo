//
//  AppDelegate.h
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PopupViewController.h"

@interface ApplicationController : NSObject <NSApplicationDelegate> {
    NSStatusItem *statusItem;
}

- (IBAction)manageWorlds:(id)sender;

@end

