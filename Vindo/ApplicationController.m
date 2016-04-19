 //
//  AppDelegate.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ApplicationController.h"
#import "LaunchController.h"
#import "UpdatePreferencesViewController.h"
#import "GeneralPreferencesViewController.h"
#import "PopupController.h"
#import "ManageWorldsWindowController.h"
#import "RunWindowController.h"

#import "World.h"
#import "WorldsController.h"
#import "NSObject+Notifications.h"

#import "PFMoveApplication.h"
#import "RHPreferences/RHPreferences.h"
#import "LaunchAtLoginController.h"

@interface ApplicationController ()

@property ManageWorldsWindowController *manageWorlds;
@property RHPreferencesWindowController *preferences;
@property IBOutlet RunWindowController *runBox;

@property IBOutlet LaunchController *launcher;
@property IBOutlet PopupController *popupController;

@end

@implementation ApplicationController

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
#ifndef DEBUG
    PFMoveToApplicationsFolderIfNecessary();
#endif
    self.preferences = [[RHPreferencesWindowController alloc]
                        initWithViewControllers:@[
                                                  [GeneralPreferencesViewController new],
                                                  [UpdatePreferencesViewController new]
                                                  ]];
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

- (IBAction)runOtherProgram:(id)sender {
    [self.runBox showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showCDriveInFinder:(id)sender {
    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:
     [[WorldsController sharedController].selectedWorld.url URLByAppendingPathComponent:@"drive_c"].path];
}

- (IBAction)manageWorlds:(id)sender {
    if (self.manageWorlds == nil)
        self.manageWorlds = [ManageWorldsWindowController new];
    [self.manageWorlds showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showPreferences:(id)sender {
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
