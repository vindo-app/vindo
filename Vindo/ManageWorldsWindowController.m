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

@property IBOutlet NSTableView *table;

@property (weak) IBOutlet NSButton *removeButton;
@property (weak) IBOutlet NSMenuItem *duplicateItem;

@property NSTimer *refreshTimer; // the ol' timer solution

@end

@implementation ManageWorldsWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@"ManageWorlds"];
}

- (void)awakeFromNib {
    [self.table registerForDraggedTypes:@[WorldPasteboardType]];
    
    [self.arrayController addObserver:self
                           forKeyPath:@"selectedObjects"
                              options:NSKeyValueObservingOptionInitial
                              context:NULL];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    self.removeButton.enabled = self.arrayController.selectedObjects.count > 0;
    self.duplicateItem.enabled = self.arrayController.selectedObjects.count == 1;
}

#pragma mark -
#pragma mark Creating Worlds

- (IBAction)addWorld:(id)sender {
    self.queryText.stringValue = @"";
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
        self.statusWindow = [[StatusWindowController alloc] initWithMessage:[NSString stringWithFormat:@"Creating world \"%@\"…", worldName]
                                                                sheetWindow:self.window];
        [self addWorldNamed:worldName];
        
    }
    [NSApp endSheet:_querySheet];
    [_querySheet orderOut:self];
}

#pragma mark -
#pragma mark Removing Worlds

- (IBAction)removeWorld:(id)sender {
    if ([_arrayController.selectedObjects indexOfObject:[[WorldsController sharedController] selectedWorld]] != NSNotFound) {
        NSBeginAlertSheet(@"The selected world cannot be deleted.",
                          @"OK", nil, nil, self.window, nil, nil, nil, NULL,
                          @"Select a different world before deleting this one.");
        return;
    }
    if (_arrayController.selectedObjects.count < 1)
        return; // don't bother deleting nothing
    
    NSMutableArray *worldsToDelete = [self.arrayController.selectedObjects mutableCopy];
    
    NSString *message;
    if (worldsToDelete.count == 1)
        message = [NSString stringWithFormat:@"Deleting world \"%@\"…",
                   [worldsToDelete[0] displayName]];
    else
        message = [NSString stringWithFormat:@"Deleting %lu worlds…",
                   (unsigned long) worldsToDelete.count];
    
    self.statusWindow = [[StatusWindowController alloc] initWithMessage:message sheetWindow:self.window];

    [self removeWorlds:worldsToDelete];
}

- (IBAction)duplicateWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    self.statusWindow = [[StatusWindowController alloc] initWithMessage:[NSString stringWithFormat:@"Duplicating world \"%@\"…", world.displayName] sheetWindow:self.window];
    [self duplicateThisWorld:self.arrayController.selectedObjects[0]];
}

- (IBAction)startWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    [world start];
}

- (IBAction)shutdownWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    if (world == [WorldsController sharedController].selectedWorld) {
        NSBeginAlertSheet(@"The selected world can't be shut down.",
                          @"OK", nil, nil, self.window, nil, nil, nil, NULL,
                          @"Select a different world before shutting down this one.");
        return;
    }
    if (world.running)
        [world stop];
}

- (IBAction)rebootWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    [world run:@"wineboot" withArguments:@[@"--restart"]];
}

#pragma mark Table View Stuff

- (void)refresh:(NSTimer *)timer {
    [self.table reloadData];
}

-           (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                      row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"world"]) {
        return [self.arrayController.arrangedObjects[row] displayName];
    } else if ([tableColumn.identifier isEqualToString:@"selected"]) {
        return @(self.arrayController.arrangedObjects == [WorldsController sharedController].selectedWorld);
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(nonnull id)cell forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"status"]) {
        NSImageCell *imageCell = cell;
        World *world = self.arrayController.arrangedObjects[row];
        if (world.running)
            imageCell.image = [NSImage imageNamed:NSImageNameStatusAvailable];
        else
            imageCell.image = nil;
    } else if ([tableColumn.identifier isEqualToString:@"selected"]) {
        NSButtonCell *buttonCell = cell;
        World *world = self.arrayController.arrangedObjects[row];
        if (world == [WorldsController sharedController].selectedWorld)
            buttonCell.state = NSOnState;
        else
            buttonCell.state = NSOffState;
    }
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
    if ([tableColumn.identifier isEqualToString:@"world"]) {
        World *world = self.arrayController.arrangedObjects[row];
        [self renameWorld:world toName:object];
    } else if ([tableColumn.identifier isEqualToString:@"selected"]) {
        [WorldsController sharedController].selectedObjects = @[self.arrayController.arrangedObjects[row]];
    }
}

@end
