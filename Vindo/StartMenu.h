//
//  StartMenu.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import <CDEvents/CDEventsDelegate.h>

@interface StartMenu : NSObject <CDEventsDelegate>

@property (readonly) NSArray *items;

- (id)initWithWorld:(World *)world;

@end
