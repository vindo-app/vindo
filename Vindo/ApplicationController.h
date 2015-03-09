

//
//  AppDelegate.h
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RHPreferences/RHPreferences.h>
#import "GeneralPreferencesViewController.h"
#import "WineCfgViewController.h"
#import "WinePrefix.h"

@interface ApplicationController : NSObject <NSApplicationDelegate> {
    WinePrefix *prefix;
    NSStatusItem *statusItem;
    RHPreferencesWindowController *prefs;
}

@property (assign) IBOutlet NSMenu *statusBarMenu;

- (IBAction)showPreferences:(id)sender;

@end

