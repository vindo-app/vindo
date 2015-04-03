//
//  BrowserController.h
//  Vindo
//
//  Created by Theodore Dubois on 3/29/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Item.h"

@interface BrowserController : NSWindowController <NSWindowDelegate>

@property Item *rootItem;

@end
