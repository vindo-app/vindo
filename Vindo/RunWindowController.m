//
//  RunWindowController.m
//  Vindo
//
//  Created by Theodore Dubois on 4/6/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "RunWindowController.h"
#import "LaunchController.h"

@interface RunWindowController ()

@property (weak) IBOutlet NSTextField *box;
@property (weak) IBOutlet LaunchController *launcher;

@end

@implementation RunWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@"RunWindowController"];
}

- (IBAction)run:(id)sender {
    NSString *what = self.box.stringValue;
    if ([what characterAtIndex:0] == '/')
        [self.launcher run:@"start" withArguments:@[@"/unix", what]];
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
    [browser runModal];
    self.box.stringValue = browser.URL.path;
}

@end