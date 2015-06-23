//
//  WorldsController.m
//  Vindo
//
//  Created by Theodore Dubois on 6/5/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsController.h"
#import "WorldsTransformer.h"
#import "IndexSetToIntTransformer.h"

static WorldsController *sharedController;

@implementation WorldsController

- (id)init {
    if (sharedController != nil)
        return sharedController;
    
    if (self = [super init]) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        
        [[defaults defaults] registerDefaults:@{
                                               @"worlds": @[@"Default World"],
                                               @"selectedWorldIndex": @0
                                               }];
        
        [self bind:@"contentArray"
          toObject:defaults
       withKeyPath:@"values.worlds"
           options:@{
                     NSValueTransformerBindingOption: [WorldsTransformer new],
                     NSRaisesForNotApplicableKeysBindingOption: @YES,
                     NSHandlesContentAsCompoundValueBindingOption: @YES
                     }];
        [self bind:@"selectionIndexes"
          toObject:defaults
       withKeyPath:@"values.selectedWorldIndex"
           options:@{
                     NSValueTransformerBindingOption: [IndexSetToIntTransformer new],
                     NSRaisesForNotApplicableKeysBindingOption: @YES
                     }];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(sharedController != nil, @"shared controller must exist by the time nib is loaded");
    return sharedController;
}

- (World *)selectedWorld {
    return self.arrangedObjects[self.selectionIndex];
}

+ (WorldsController *)sharedController {
    return sharedController;
}

+ (void)initialize {
    sharedController = [WorldsController new];
}

@end
