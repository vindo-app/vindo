 //
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "ApplicationController.h"
#import "LaunchController.h"
#import "UpdatePreferencesViewController.h"
#import "GeneralPreferencesViewController.h"
#import "PopupController.h"
#import "ManageWorldsWindowController.h"

#import "World.h"
#import "WorldsController.h"
#import "NSObject+Notifications.h"

#import "PFMoveApplication.h"
#import "RHPreferences/RHPreferences.h"
#import "LaunchAtLoginController.h"

@interface ApplicationController ()

@property ManageWorldsWindowController *manageWorlds;
@property RHPreferencesWindowController *preferences;

@property IBOutlet LaunchController *launcher;
@property IBOutlet PopupController *popupController;

@end

@implementation ApplicationController

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
#ifndef DEBUG
    PFMoveToApplicationsFolderIfNecessary();
    [LaunchAtLoginController new].launchAtLogin = YES;
#endif
    
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:NSApp queue:nil usingBlock:^(NSNotification *notification) {
        if (!([notification.name isEqualToString:NSApplicationWillUpdateNotification] ||
              [notification.name isEqualToString:NSApplicationDidUpdateNotification] ||
              [notification.name isEqualToString:NSApplicationDidChangeOcclusionStateNotification]))
            NSLog(@"%@", notification);
    }];
#endif
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [self.launcher launch:[NSURL fileURLWithPath:filename]];
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    for (NSString *file in filenames)
        [self application:sender openFile:file];
}

- (IBAction)controlPanels:(id)sender {
    [self.launcher run:@"control"];
}

- (IBAction)simulateReboot:(id)sender {
    [self.launcher run:@"wineboot" withArguments:@[@"--restart"]];
}

- (IBAction)commandPrompt:(id)sender {
    [self.launcher run:@"start" withArguments:@[@"cmd"]];
}

- (IBAction)showCDriveInFinder:(id)sender {
    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:[[WorldsController sharedController].selectedWorld.url URLByAppendingPathComponent:@"drive_c"].path];
}

- (IBAction)manageWorlds:(id)sender {
    if (self.manageWorlds == nil)
        self.manageWorlds = [ManageWorldsWindowController new];
    [self.manageWorlds showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showPreferences:(id)sender {
    if (self.preferences == nil)
        self.preferences = [[RHPreferencesWindowController alloc]
                            initWithViewControllers:@[
                                                      [GeneralPreferencesViewController new],
                                                      [UpdatePreferencesViewController new]
                                                      ]];
    [self.preferences showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

static NSInteger nWorlds = -1;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EliminatePopup" object:self];
    
    if (nWorlds == 0)
        return NSTerminateNow;
    if (nWorlds != -1)
        return NSTerminateLater;
    
    NSArray *worlds = [WorldsController sharedController].arrangedObjects;
    nWorlds = worlds.count;
    
    for (World *world in worlds) {
        if (world.running) {
            [world onNext:WorldDidStopNotification do:^(id n) {
                if (--nWorlds == 0)
                    [NSApp terminate:nil];
            }];
            [world stop];
        } else {
            nWorlds--;
        }
    }
    if (nWorlds == 0)
        return NSTerminateNow;
    return NSTerminateLater;
}

@end
