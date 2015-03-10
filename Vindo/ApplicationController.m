//
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ApplicationController.h"

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
    
    prefix = [[WinePrefix alloc] initWithPath:[self defaultPrefixPath]];
#ifdef DEBUG
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(notificationSpy:)
                   name:nil
                 object:prefix];
#endif
    [prefix startServer];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
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

- (void)dealloc {
    [prefix stopServer];
    
}

#ifdef DEBUG
- (void)notificationSpy:(NSNotification *)notification {
    NSLog(@"%@", notification);
}
#endif

@end
