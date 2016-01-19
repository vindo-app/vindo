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

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

@end
