//
//  AppDelegate.h
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ApplicationController : NSObject <NSApplicationDelegate> {
    NSStatusItem *statusItem;
}

@property IBOutlet NSMenu *statusBarMenu;

- (IBAction)runCannedProgram:(id)sender;
- (IBAction)runProgram:(id)sender;
- (IBAction)manageWorlds:(id)sender;

@end
