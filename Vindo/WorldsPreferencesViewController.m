//
//  WorldsPreferencesViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "WorldsPreferencesViewController.h"
#import "WorldsPreferencesArrayController.h"
#import "CreateWorldTask.h"
#import "NSOperationQueue+DefaultQueue.h"

@interface WorldsPreferencesViewController ()

@property IBOutlet NSWindow *querySheet;
@property IBOutlet NSTextField *queryText;

@property IBOutlet WorldsPreferencesArrayController *arrayController;

@end

@implementation WorldsPreferencesViewController

- (instancetype)init {
    return [super initWithNibName:@"WorldsPreferences" bundle:nil];
}

- (IBAction)addWorld:(id)sender {
    [NSApp beginSheet:_querySheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)querySheetDidEnd:(NSButton *)sender {
    [NSApp endSheet:_querySheet returnCode:[sender tag]];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 0) {
        [[NSOperationQueue defaultQueue] addOperation:
         [[CreateWorldTask alloc] initWithWorldName:_queryText.stringValue arrayController:_arrayController]];
    }
    [NSApp endSheet:_querySheet];
    [_querySheet orderOut:self];
}

- (IBAction)removeWorld:(id)sender {
}

- (NSString *)toolbarItemLabel {
    return @"Worlds";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNameNetwork];
}

- (NSString *)identifier {
    return self.className;
}

@end
