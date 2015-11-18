//
//  PopupController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rebel/Rebel.h>
#import "PopupViewController.h"

@interface PopupController : NSObject

@property IBOutlet PopupViewController *popupViewController;
@property RBLPopover *popover;
@property NSStatusItem *statusItem;

@end
