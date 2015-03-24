//
//  NSOperationQueue+DefaultQueue.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/24/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "NSOperationQueue+DefaultQueue.h"

@implementation NSOperationQueue (DefaultQueue)

static NSOperationQueue *defaultQueue;

+ (NSOperationQueue *)defaultQueue {
    if (defaultQueue == nil) {
        @synchronized(self) {
            if (defaultQueue == nil) {
                defaultQueue = [self new];
            }
        }
    }
    
    return defaultQueue;
}

@end
