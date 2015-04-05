//
//  BrowserDelegate.h
//  Vindo
//
//  Created by Theodore Dubois on 4/5/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrowserController.h"

@interface BrowserDelegate : NSObject <NSBrowserDelegate>

@property BrowserController *controller;

@end
