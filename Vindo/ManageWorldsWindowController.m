//
//  WorldsPreferencesViewController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsController.h"
#import "World.h"
#import "ManageWorldsWindowController.h"
#import "StatusWindowController.h"
#import "NSObject+Notifications.h"

@interface ManageWorldsWindowController ()

@property IBOutlet NSWindow *querySheet;
@property IBOutlet NSTextField *queryText;

@property IBOutlet NSArrayController *arrayController;
@property IBOutlet NSTableView *table;

@property StatusWindowController *statusWindow;

@end

@implementation ManageWorldsWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@"ManageWorlds"];
}

#pragma mark -
#pragma mark Creating Worlds

- (IBAction)addWorld:(id)sender {
    [NSApp beginSheet:_querySheet
       modalForWindow:self.window
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
        
        
        World *world = [[World alloc] initWithName:worldName];
        
        self.statusWindow = [[StatusWindowController alloc] initWithMessage:[NSString stringWithFormat:@"Creating world \"%@\"…", worldName]
                                                                sheetWindow:self.window];
        [self.statusWindow appear];
        
        [world onNext:WorldDidStartNotification
                   do:^(id n) {
                       [self.arrayController addObject:world];
                       self.arrayController.selectedObjects = @[world];
                       [self.statusWindow disappear];
                   }];
        [world start];
        
    }
    [NSApp endSheet:_querySheet];
    [_querySheet orderOut:self];
}

#pragma mark -
#pragma mark Removing Worlds

- (IBAction)removeWorld:(id)sender {
    if ([_arrayController.selectedObjects indexOfObject:[[WorldsController sharedController] selectedWorld]] != NSNotFound) {
        NSBeginAlertSheet(@"The default world cannot be deleted.",
                          @"OK", nil, nil, self.window, nil, nil, nil, NULL,
                          @"Select another world in the \"Worlds\" menu before deleting this one.");
        return;
    }
    if (_arrayController.selectedObjects.count < 1)
        return; // don't bother deleting nothing
    
    NSArray *worldsToDelete = self.arrayController.selectedObjects;
    
    NSString *message;
    if (worldsToDelete.count == 1)
        message = [NSString stringWithFormat:@"Deleting world \"%@\"…",
                   [worldsToDelete[0] name]];
    else
        message = [NSString stringWithFormat:@"Deleting %lu worlds…",
                   (unsigned long) worldsToDelete.count];
    
    for (World *world in worldsToDelete) {
        // FIXME: there's no progress indicator
        [world onNext:WorldDidStopNotification
                   do:^(id n) {
                       [[NSFileManager defaultManager] trashItemAtURL:world.url
                                                     resultingItemURL:nil
                                                                error:nil]; // move world to trash
                       [self.arrayController removeObject:world]; // remove object from worlds
                   }];
        [world stop];
    }
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

@end
