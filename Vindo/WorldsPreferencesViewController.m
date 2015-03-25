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
#import "NSOperationQueue+DefaultQueue.h"
#import "CreateWorldTask.h"
#import "DeleteWorldTask.h"

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
         [[CreateWorldTask alloc] initWithWorldName:_queryText.stringValue
                                    arrayController:_arrayController
                                        sheetWindow:self.view.window]];
    }
    [NSApp endSheet:_querySheet];
    [_querySheet orderOut:self];
}

- (IBAction)removeWorld:(id)sender {
    if ([_arrayController.selectedObjects indexOfObject:[World defaultWorld]] != NSNotFound) {
        NSBeginAlertSheet(@"The default world cannot be deleted.",
                          @"OK", nil, nil, self.view.window, nil, nil, nil, NULL,
                          @"Select another world in the \"Worlds\" menu before deleting this one.");
        return;
    }
    if (_arrayController.selectedObjects.count < 1)
        return; // don't bother deleting nothing
    [[NSOperationQueue defaultQueue] addOperation:
     [[DeleteWorldTask alloc] initWithArrayController:self.arrayController sheetWindow:self.view.window]];
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
