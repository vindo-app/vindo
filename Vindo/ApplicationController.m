//
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ApplicationController.h"
#import "PrefixesController.h"

@implementation ApplicationController

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"Icon16"];
    statusItem.menu = _statusBarMenu;
    
    // workaround bug in RHPreferences
    [[NSUserDefaults standardUserDefaults] registerDefaults:
        @{@"RHPreferencesWindowControllerSelectedItemIdentifier": @"GeneralPreferencesViewController"}];
    
    WinePrefix *prefix = [[WinePrefix alloc] initWithPath:[self defaultPrefixPath]];
    [PrefixesController sharedController].defaultPrefix = prefix;
#ifdef DEBUG
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(notificationSpy:)
                   name:nil
                 object:prefix];
#endif
    [prefix startServer];
}

- (void)runCannedProgram:(id)sender {
    WinePrefix *prefix = [PrefixesController defaultPrefix];
    
    switch ([sender tag]) {
        case 0: // file manager
            [prefix run:@"winefile"];
            break;
        case 1: // internet explorer
            [prefix run:@"iexplore"];
            break;
        case 2: // minesweeper
            [prefix run:@"winemine"];
            break;
        case 3: // notepad
            [prefix run:@"notepad"];
            break;
        case 4: // console
            [prefix run:@"wineconsole" withArguments:@[@"cmd"]];
            break;
        case 5: // winecfg
            [prefix run:@"winecfg"];
            break;
        case 6: // regedit
            [prefix run:@"regedit"];
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
        WinePrefix *prefix = [PrefixesController defaultPrefix];
        
        if (result == NSFileHandlingPanelOKButton) {
            [prefix run:[panel.URLs.firstObject path]];
        }
    }];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    WinePrefix *prefix = [PrefixesController defaultPrefix];
    
    if (prefix.serverRunning) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(retryTerminateApp:)
                       name:WineServerDidStopNotification
                     object:prefix];
        [prefix stopServer];
        return NSTerminateCancel;
    } else
        return NSTerminateNow;
}

- (void)retryTerminateApp:(NSNotification *)notifications {
    [NSApp terminate:self];
}
              
- (NSURL *)defaultPrefixPath {
    return [[NSURL fileURLWithPath:NSHomeDirectory()] URLByAppendingPathComponent:@"Wine Files"];
}

- (IBAction)showPreferences: (id)sender {
    if (prefs == nil) {
        prefs = [[RHPreferencesWindowController alloc] initWithViewControllers:
                                 @[
                                   [RHPreferencesWindowController flexibleSpacePlaceholderController],
                                   [GeneralPreferencesViewController new],
                                   [WineCfgViewController new],
                                   [RHPreferencesWindowController flexibleSpacePlaceholderController]
                                  ]];
        // workaround for missing behavior in RHPreferences
        prefs.window.collectionBehavior =
            NSWindowCollectionBehaviorMoveToActiveSpace |
            NSWindowCollectionBehaviorFullScreenAuxiliary;
    }
    [prefs showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

#ifdef DEBUG
- (void)notificationSpy:(NSNotification *)notification {
    NSLog(@"%@", notification);
}
#endif

@end
