//
//  WorldsPreferencesViewController.h
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatusWindowController.h"
#import "World.h"

@interface ManageWorldsWindowController : NSWindowController <NSTableViewDataSource>

@property IBOutlet NSArrayController *arrayController;
@property StatusWindowController *statusWindow;

@end

@interface ManageWorldsWindowController (Operations)

- (void)addWorldNamed:(NSString *)name;
- (void)removeWorlds:(NSArray *)worlds;

- (void)renameWorld:(World *)world toName:(NSString *)name;

@end
