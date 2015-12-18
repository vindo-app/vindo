//
//  World+StartMenu.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/18/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "World+StartMenu.h"

@implementation World (StartMenu)

- (NSURL *)programsFolder {
    return [self.url URLByAppendingPathComponent:@"menu/programs"];
}

@end
