//
//  WineServer.m
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServer.h"

@implementation WineServer

- (void)runExe:(NSString *)exePath {
    NSAlert *alert = [NSAlert alertWithMessageText:@"That option does nothing" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"That's because this is a non-functioning prototype."];
    [alert runModal];
}

@end
