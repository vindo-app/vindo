//
//  LaunchController.m
//  Vindo
//
//  Created by Theodore Dubois on 6/26/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "LaunchController.h"
#import "WorldsController.h"
#import "Parsing.h"

@implementation LaunchController

- (void)run:(NSString *)program {
    [self run:program withArguments:@[]];
}

- (void)run:(NSString *)program withArguments:(NSArray *)arguments {
    [[WorldsController sharedController].selectedWorld run:program
                                             withArguments:arguments];
}

- (void)launch:(NSURL *)thing {
    [self run:@"start" withArguments:@[windowsPathFromUnixPath(thing.path, [WorldsController sharedController].selectedWorld)]];
}

@end
