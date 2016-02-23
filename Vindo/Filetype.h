//
//  Filetype.h
//  Vindo
//
//  Created by Theodore Dubois on 1/29/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import "AppBundle.h"

@interface Filetype : NSObject

@property (readonly) NSString *filetypeId;
@property (readonly) NSArray *extensions;
@property (readonly) NSString *progId;
@property (readonly) NSString *command;
@property (readonly) NSString *executable;
@property (readonly) NSString *docName;
@property (readonly) NSString *appName;
@property (readonly) NSURL *docIconURL;
@property (readonly) NSURL *appIconURL;
@property (readonly) NSImage *docIcon;
@property (readonly) NSImage *appIcon;

@property (readonly) World *world;
@property (readonly) AppBundle *bundle;

- (id)initWithFiletypeId:(NSString *)filetypeId inWorld:(World *)world;

@end
