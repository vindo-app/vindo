//
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ApplicationController.h"
#import "BrowserController.h"
#import "GeneralPreferencesViewController.h"
#import "WineCfgViewController.h"
#import "WorldsPreferencesViewController.h"
#import "World.h"

@interface ApplicationController ()

@property RHPreferencesWindowController *prefs;

@end

@implementation ApplicationController

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    World *world = [World defaultWorld];
#ifdef DEBUG
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(notificationSpy:)
                   name:nil
                 object:world];
#endif
    [world start];
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"Icon16"];
    statusItem.menu = _statusBarMenu;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    World *world = [World defaultWorld];
    [world run:filename];
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    for (NSString *file in filenames)
        [self application:sender openFile:file];
}

- (void)runCannedProgram:(id)sender {
    World *world = [World defaultWorld];
    
    switch ([sender tag]) {
        case 0: // file manager
            [world run:@"winefile"];
            break;
        case 1: // internet explorer
            [world run:@"iexplore"];
            break;
        case 2: // minesweeper
            [world run:@"winemine"];
            break;
        case 3: // notepad
            [world run:@"notepad"];
            break;
        case 4: // console
            [world run:@"wineconsole" withArguments:@[@"cmd"]];
            break;
        case 5: // winecfg
            [world run:@"winecfg"];
            break;
        case 6: // regedit
            [world run:@"regedit"];
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
        World *world = [World defaultWorld];
        
        if (result == NSFileHandlingPanelOKButton) {
            [world run:[panel.URLs.firstObject path]];
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

#ifdef DEBUG
- (void)notificationSpy:(NSNotification *)notification {
    NSLog(@"%@", notification);
}
#endif

@end
