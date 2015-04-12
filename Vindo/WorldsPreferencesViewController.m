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
@property IBOutlet NSTableView *table;

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
            NSError *error;
            [[NSFileManager defaultManager]
                trashItemAtURL:world.path resultingItemURL:nil error:&error]; // move world to trash
            if (error != nil) {
                [NSApp presentError:error];
                continue;
            }
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


-           (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                      row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"world"]) {
        return [self.arrayController.arrangedObjects[row] name];
    }
    return nil;
}

- (void)awakeFromNib {
    [self.table registerForDraggedTypes:@[WorldPasteboardType]];
}

-    (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
        toPasteboard:(NSPasteboard *)pboard {
    return [pboard writeObjects:[self.arrayController.arrangedObjects objectsAtIndexes:rowIndexes]];
}

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (dropOperation == NSTableViewDropOn)
        return NSDragOperationNone;
    
    if ([[info draggingPasteboard] canReadItemWithDataConformingToTypes:@[WorldPasteboardType]])
        return NSDragOperationMove;
    else
        return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)destination
    dropOperation:(NSTableViewDropOperation)dropOperation {
    World *worldToDrop = [[info draggingPasteboard] readObjectsForClasses:@[[World class]] options:nil][0];
    if ([self.arrayController.arrangedObjects indexOfObject:worldToDrop] < destination)
        destination--;
    [self.arrayController removeObject:worldToDrop];
    [self.arrayController insertObject:worldToDrop atArrangedObjectIndex:destination];
    return YES;
}

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    // not implemented yet
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
