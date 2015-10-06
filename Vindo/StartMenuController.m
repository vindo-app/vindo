//
//  StartMenuController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuController.h"

@implementation StartMenuController

- (instancetype)init {
    if (self = [super init]) {
        _menu = [StartMenu new];
    }
    return self;
}

@end
