//
//  Parsing.h
//  Vindo
//
//  Created by Theodore Dubois on 2/24/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"

NSString *programFromCommand(NSString *command);
NSArray *argumentsFromCommand(NSString *command);

NSArray *splitArguments(NSString *arguments);

NSString *windowsPathFromUnixPath(NSString *unix, World *world);