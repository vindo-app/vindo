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
@property (weak) IBOutlet NSMenuItem *importItem;
@property (weak) IBOutlet NSMenuItem *exportItem;

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
    self.duplicateItem.enabled = self.exportItem.enabled = self.arrayController.selectedObjects.count == 1;
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
        self.statusWindow = [[StatusWindowController alloc] initWithMessage:[NSString stringWithFormat:@"Creating \"%@\"…", worldName]
                                                                sheetWindow:self.window];
        [self addWorldNamed:worldName];
        
    }
    [NSApp endSheet:_querySheet];
    [_querySheet orderOut:self];
}

#pragma mark -
#pragma mark Removing Worlds

- (IBAction)removeWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    if ([[WorldsController sharedController] selectedWorld] == world) {
        NSBeginAlertSheet(@"The selected world cannot be deleted.",
                          @"OK", nil, nil, self.window, nil, nil, nil, NULL,
                          @"Select a different world before deleting this one.");
        return;
    }
    NSAlert *confirmation = [NSAlert new];
    confirmation.messageText = [NSString stringWithFormat:@"Are you sure you want to delete \"%@\"?", world.name];
    confirmation.informativeText = @"A copy of the world will be moved to the Trash. You can restore it by dragging it out of the trash and importing it.";
    [confirmation addButtonWithTitle:@"Delete"];
    [confirmation addButtonWithTitle:@"Cancel"];
    [confirmation beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse response) {
        if (response == NSAlertFirstButtonReturn) {
            self.statusWindow = [[StatusWindowController alloc] initWithMessage:
                                 [NSString stringWithFormat:@"Deleting \"%@\"…", world.name] sheetWindow:self.window];
            [self removeThisWorld:world];
        }
    }];
}

- (IBAction)duplicateWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    self.statusWindow = [[StatusWindowController alloc] initWithMessage:
                         [NSString stringWithFormat:@"Duplicating \"%@\"…", world.name] sheetWindow:self.window];
    [self duplicateThisWorld:self.arrayController.selectedObjects[0]];
}

- (IBAction)import:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.prompt = @"Import";
    openPanel.delegate = self;
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *worldURL = openPanel.URL;
            NSString *worldName = [worldURL lastPathComponent];
            self.statusWindow = [[StatusWindowController alloc] initWithMessage:
                                 [NSString stringWithFormat:@"Importing \"%@\"…", worldName] sheetWindow:self.window];
            [self importWorldAt:worldURL];
        }
    }];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)outError {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isValid = YES;
    if (![fm fileExistsAtPath:[url URLByAppendingPathComponent:@"dosdevices"].path isDirectory:&isDir] || !isDir)
        isValid = NO;
    if (![fm fileExistsAtPath:[url URLByAppendingPathComponent:@"system.reg"].path isDirectory:&isDir] || isDir)
        isValid = NO;
    if (![fm fileExistsAtPath:[url URLByAppendingPathComponent:@"user.reg"].path isDirectory:&isDir] || isDir)
        isValid = NO;
    if (![fm fileExistsAtPath:[url URLByAppendingPathComponent:@"userdef.reg"].path isDirectory:&isDir] || isDir)
        isValid = NO;
    
    if (!isValid) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:44 userInfo:@{NSLocalizedDescriptionKey: @"Please select a world."}];
    }
    return isValid;
}

- (IBAction)export:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.prompt = @"Export";
    savePanel.nameFieldLabel = @"Export As:";
    savePanel.nameFieldStringValue = world.name;
    savePanel.showsTagField = NO;
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *exportName = savePanel.nameFieldStringValue;
            NSURL *exportDestination = [savePanel.directoryURL URLByAppendingPathComponent:exportName];
            self.statusWindow = [[StatusWindowController alloc] initWithMessage:
                                 [NSString stringWithFormat:@"Exporting \"%@\" as \"%@\"…", world.name, exportName] sheetWindow:self.window];
            [self exportWorld:self.arrayController.selectedObjects[0] to:exportDestination];
        }
    }];
}

- (IBAction)rebootWorld:(id)sender {
    World *world = self.arrayController.selectedObjects[0];
    [world run:@"wineboot" withArguments:@[@"--restart"]];
}

- (IBAction)whatAreWorlds:(id)sender {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"About Worlds";
    alert.informativeText = @"A world is a container that Windows programs are installed in. All your Windows programs and settings are world-specific.\n\n"
        @"When you install Vindo, a world called Default World is created for you. Most of the time, you don't need another world.";
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark Table View Stuff

- (void)refresh:(NSTimer *)timer {
    if (self.table.editedRow == -1)
        [self.table reloadData];
}

-           (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                      row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"world"]) {
        return [self.arrayController.arrangedObjects[row] name];
    } else if ([tableColumn.identifier isEqualToString:@"selected"]) {
        return @(self.arrayController.arrangedObjects == [WorldsController sharedController].selectedWorld);
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(nonnull id)cell forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"selected"]) {
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
