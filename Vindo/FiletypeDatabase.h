//
//  FiletypeDatabase.h
//  Vindo
//
//  Created by Theodore Dubois on 1/29/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEventsDelegate.h>
#import "World.h"

@interface FiletypeDatabase : NSObject <CDEventsDelegate>

- (id)initWithWorld:(World *)world;

@property (readonly) NSArray *filetypes;

@end
