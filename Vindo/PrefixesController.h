//
//  PrefixesController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/10/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinePrefix.h"

@interface PrefixesController : NSObject

+ (PrefixesController *)sharedController;
+ (WinePrefix *)defaultPrefix;

@property WinePrefix *defaultPrefix;

@end
