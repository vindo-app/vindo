//
//  PrefixesController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/10/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "PrefixesController.h"

static PrefixesController *controller;

@implementation PrefixesController

+ (PrefixesController *)sharedController {
    // double-check locking
    if (controller == nil) {
        @synchronized (self) {
            if (controller == nil) {
                controller = [self new];
            }
        }
    }
    return controller;
}

+ (WinePrefix *)defaultPrefix {
    return [self sharedController].defaultPrefix;
}

@end
