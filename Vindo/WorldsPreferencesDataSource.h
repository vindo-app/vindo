//
//  WorldsPreferencesDataSource.h
//  Vindo
//
//  Created by Theodore Dubois on 3/23/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldsPreferencesArrayController.h"

@interface WorldsPreferencesDataSource : NSObject <NSTableViewDataSource>
@property IBOutlet WorldsPreferencesArrayController *arrayController;

@end
