//
//  WindowsProgramApplication.m
//  Vindo
//
//  Created by Theodore Dubois on 1/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "WindowsProgramApplication.h"

@implementation WindowsProgramApplication

@synthesize wineController;

- (void)sendEvent:(NSEvent *)anEvent {
    if (![wineController handleEvent:anEvent]) {
        [super sendEvent:anEvent];
        [wineController didSendEvent:anEvent];
    }
}

@end
