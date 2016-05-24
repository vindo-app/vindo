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

- (void)launch:(NSURL *)url {
    [[WorldsController sharedController].selectedWorld run:@"start"
                                             withArguments:@[windowsPathFromUnixPath(url.path, [WorldsController sharedController].selectedWorld)]
                                               inDirectory:url.URLByDeletingLastPathComponent.path];
}

- (void)launchProgram:(NSString *)program {
    if ([program characterAtIndex:0] == '/')
        [[WorldsController sharedController].selectedWorld run:@"start"
                                                 withArguments:@[windowsPathFromUnixPath(program, [WorldsController sharedController].selectedWorld)]
                                                   inDirectory:[program stringByDeletingLastPathComponent]];
    else
        [[WorldsController sharedController].selectedWorld run:@"start"
                                                 withArguments:@[program]
                                                   inDirectory:[unixPathFromWindowsPath(program, [WorldsController sharedController].selectedWorld)
                                                                stringByDeletingLastPathComponent]];
}

@end