//
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ApplicationController.h"

@implementation ApplicationController
@synthesize statusBarMenu;

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    [statusItem retain];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"Icon16"];
    statusItem.menu = statusBarMenu;
    
    // workaround bug in RHPreferences
    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObject:@"GeneralPreferencesViewController"
                                    forKey:@"RHPreferencesWindowControllerSelectedItemIdentifier"]];
    
    prefix = [[WinePrefix alloc] initWithPath:[self defaultPrefixPath]];
#ifdef DEBUG
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(prefixNotificationSpy:)
                   name:nil
                 object:prefix];
#endif
    [prefix startServer];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if ([prefix isServerRunning]) {
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
                                 [NSArray arrayWithObjects:
                                  [RHPreferencesWindowController flexibleSpacePlaceholderController],
                                  [[GeneralPreferencesViewController new] autorelease],
                                  [[WineCfgViewController new] autorelease],
                                  [RHPreferencesWindowController flexibleSpacePlaceholderController],
                                  nil]];
        // workaround for missing behavior in RHPreferences
        prefs.window.collectionBehavior =
            NSWindowCollectionBehaviorMoveToActiveSpace |
            NSWindowCollectionBehaviorFullScreenAuxiliary;
    }
    [prefs showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)dealloc {
    [statusItem release];
    [prefix stopServer];
    [prefix release];
    
    [super dealloc];
}

#ifdef DEBUG
- (void)prefixNotificationSpy:(NSNotification *)notification {
    NSLog(@"%@", notification);
}
#endif

@end
