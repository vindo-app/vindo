//
//  WorldsPreferencesViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "World.h"
#import "WorldsPreferencesViewController.h"
#import "StatusWindowController.h"
#import "NSOperationQueue+DefaultQueue.h"

@interface WorldsPreferencesViewController ()

@property IBOutlet NSWindow *querySheet;
@property IBOutlet NSTextField *queryText;

@property IBOutlet NSArrayController *arrayController;

@property id strongReference; // need a strong reference to the sheet

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
        NSString *worldName = self.queryText.stringValue;
        [self runBlock:^{
            World *world = [World worldNamed:worldName];
            [world startAndWait];
            [self.arrayController addObject:world];
            self.arrayController.selectedObjects = @[world];
        } message:[NSString stringWithFormat:@"Creating world \"%@\"…", worldName]];
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
    
    NSArray *worldsToDelete = self.arrayController.selectedObjects;
    
    NSString *message;
    if (worldsToDelete.count == 1)
        message = [NSString stringWithFormat:@"Deleting world \"%@\"…",
                       [worldsToDelete.firstObject name]];
    else
        message = [NSString stringWithFormat:@"Deleting %lu worlds…",
                       (unsigned long) worldsToDelete.count];

    [self runBlock:^{
        for (World *world in worldsToDelete) {
            [world stopAndWait];
            [[NSFileManager defaultManager]
                trashItemAtURL:world.path resultingItemURL:nil error:nil]; // move world to trash
            [self.arrayController removeObject:world]; // remove object from worlds
            [World deleteWorldNamed:world.name];
        }
    } message:message];
}

- (void)runBlock:(void (^)(void))block message:(NSString *)message {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:block];
    self.strongReference = [[StatusWindowController alloc] initWithMessage:message
                                                               sheetWindow:self.view.window
                                                                 operation:op];
    [[NSOperationQueue defaultQueue] addOperation:op];
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
