//
//  BrowserController.m
//  Vindo
//
//  Created by Theodore Dubois on 3/29/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "BrowserController.h"

@interface BrowserController ()

@property IBOutlet NSOutlineView *sidebar;

@end

@implementation BrowserController

- (id)init {
    return [super initWithWindowNibName:@"Browser"];
}

@end
