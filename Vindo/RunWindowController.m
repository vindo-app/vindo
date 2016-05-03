//
//  RunWindowController.m
//  Vindo
//
//  Created by Theodore Dubois on 4/6/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "RunWindowController.h"
#import "LaunchController.h"
#import "WorldsController.h"
#import "World.h"
#import "Parsing.h"

@interface RunWindowController ()

@property (weak) IBOutlet NSTextField *box;
@property (weak) IBOutlet LaunchController *launcher;

@end

@implementation RunWindowController

- (instancetype)init {
    if (self = [super initWithWindowNibName:@"RunWindowController"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDeactivated:) name:NSApplicationDidResignActiveNotification object:NSApp];
    }
    return self;
}

- (IBAction)run:(id)sender {
    NSString *what = self.box.stringValue;
    if ([what characterAtIndex:0] == '/')
        [self.launcher run:@"start" withArguments:@[windowsPathFromUnixPath(what, [WorldsController sharedController].selectedWorld)]];
    else
        [self.launcher run:@"start" withArguments:@[what]];
    [self close];
}

- (IBAction)browse:(id)sender {
    NSOpenPanel *browser = [NSOpenPanel openPanel];
    browser.canChooseFiles = YES;
    browser.canChooseDirectories = NO;
    browser.allowsMultipleSelection = NO;
    browser.prompt = @"Select";
    browser.directoryURL = [[WorldsController sharedController].selectedWorld.url URLByAppendingPathComponent:@"drive_c"];
    [browser beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
            self.box.stringValue = windowsPathFromUnixPath(browser.URL.path, [WorldsController sharedController].selectedWorld);
    }];
}

- (void)appDeactivated:(NSNotification *)notification {
    [self close];
}

@end