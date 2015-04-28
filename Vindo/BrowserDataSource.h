//
//  BrowserDataSource.h
//  Vindo
//
//  Created by Theodore Dubois on 4/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface BrowserDataSource : NSObject <NSOutlineViewDataSource, NSBrowserDelegate>

@property Item *root;

@end
