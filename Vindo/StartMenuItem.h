//
//  StartMenuItem.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import "AppBundle.h"

@interface StartMenuItem : NSObject

@property (readonly) NSString *nativeIdentifier;
@property (readonly) World *world;

@property (readonly) NSString *name;
@property (readonly) NSString *path;
@property (readonly) NSString *args;

@property (readonly) NSURL *iconURL;
@property (readonly) NSImage *icon;

@property (readonly) AppBundle *bundle;

- (instancetype)initWithNativeIdentifier:(NSString *)nativeIdentifier inWorld:(World *)world;

@end
