//
//  WineCfgViewController.h
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RHPreferences/RHPreferences.h"
#import "AppDelegate.h"

@interface WineCfgViewController : NSViewController <RHPreferencesViewControllerProtocol>

- (IBAction)runWinecfg:(id)sender;

@end
