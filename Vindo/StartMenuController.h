//
//  StartMenuController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StartMenu.h"
#import "FiletypeDatabase.h"

@interface StartMenuController : NSObject

@property (readonly) StartMenu *menu;
@property (readonly) FiletypeDatabase *filetypes;

+ (StartMenuController *)sharedInstance;

@end
