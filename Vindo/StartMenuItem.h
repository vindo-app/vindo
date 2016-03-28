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

extern NSString *const StartMenuItemPasteboardType;

@interface StartMenuItem : NSObject <NSPasteboardReading, NSPasteboardWriting>

@property (readonly) NSString *itemPath;
@property (readonly) World *world;

@property (readonly) NSString *name;
@property (readonly) NSString *path;
@property (readonly) NSString *args;
@property (readonly) NSString *explanation;
@property (readonly) NSString *tooltip;

@property (readonly) NSURL *iconURL;
@property (readonly) NSImage *icon;

@property (readonly) AppBundle *bundle;

@property NSUInteger subrank;
@property NSImage *dragImage;

- (instancetype)initWithItemPath:(NSString *)itemPath inWorld:(World *)world;

@end
