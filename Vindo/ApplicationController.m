//
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ApplicationController.h"
#import "BrowserController.h"
#import "LaunchController.h"

#import "GeneralPreferencesViewController.h"
#import "WineCfgViewController.h"
#import "WorldsPreferencesViewController.h"

#import "World.h"
#import "WinePrefix.h"
#import "WorldsController.h"

@interface ApplicationController ()

@property RHPreferencesWindowController *prefs;
@property IBOutlet LaunchController *launcher;

@end

@implementation ApplicationController

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"Icon16"];
    statusItem.menu = _statusBarMenu;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [self.launcher launch:[NSURL fileURLWithPath:filename]];
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    for (NSString *file in filenames)
        [self application:sender openFile:file];
}

- (void)runCannedProgram:(id)sender {
    switch ([sender tag]) {
        case 0: // file manager
            [self.launcher run:@"winefile"];
            break;
        case 1: // internet explorer
            [self.launcher run:@"iexplore"];
            break;
        case 2: // minesweeper
            [self.launcher run:@"winemine"];
            break;
        case 3: // notepad
            [self.launcher run:@"notepad"];
            break;
        case 4: // console
            [self.launcher run:@"wineconsole" withArguments:@[@"cmd"]];
            break;
        case 5: // winecfg
            [self.launcher run:@"winecfg"];
            break;
        case 6: // regedit
            [self.launcher run:@"regedit"];
            break;
        default:
            break;
    }
}

- (IBAction)runProgram:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = NO;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self.launcher launch:panel.URLs[0]];
        }
    }];
}

- (IBAction)manageWorlds:(id)sender {
    [self showPreferences:self];
    _prefs.selectedIndex = 2;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (IBAction)showPreferences: (id)sender {
    if (_prefs == nil) {
        _prefs = [[RHPreferencesWindowController alloc] initWithViewControllers:
                                 @[
                                   [GeneralPreferencesViewController new],
                                   [WineCfgViewController new],
                                   [WorldsPreferencesViewController new],
                                  ]];
        // workaround for missing behavior in RHPreferences
        _prefs.window.collectionBehavior =
            NSWindowCollectionBehaviorMoveToActiveSpace |
            NSWindowCollectionBehaviorFullScreenAuxiliary;
    }
    [_prefs showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showBrowser: (id)sender {
    [[BrowserController new] showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
