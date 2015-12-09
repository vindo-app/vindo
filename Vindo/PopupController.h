//
//  PopupController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PopupViewController.h"

@interface PopupController : NSObject

@property PopupViewController *pvc;
@property NSPopover *popover;
@property NSStatusItem *statusItem;

@end
