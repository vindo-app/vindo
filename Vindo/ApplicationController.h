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
    NSStatusItem *statusItem;
    RHPreferencesWindowController *prefs;
}

@property (weak) IBOutlet NSMenu *statusBarMenu;

- (IBAction)showPreferences:(id)sender;
- (IBAction)runCannedProgram:(id)sender;
- (IBAction)runProgram:(id)sender;

@end

