//
//  NSURL+Relativize.m
//  Vindo
//
//  Created by Theodore Dubois on 1/28/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "NSURL+Relativize.h"

@implementation NSURL (Relativize)

- (NSString *)pathRelativeToURL:(NSURL *)from {
    NSMutableArray *fromPC = from.pathComponents.mutableCopy;
    NSMutableArray *toPC = self.pathComponents.mutableCopy;
    
    while (fromPC.count > 0 && toPC.count > 0 &&
           [fromPC[0] isEqualToString:toPC[0]]) {
        [fromPC removeObjectAtIndex:0];
        [toPC removeObjectAtIndex:0];
    }
    
    for (int i = 0; i < fromPC.count; i++)
        [toPC insertObject:@".." atIndex:0];
    
    return [NSString pathWithComponents:toPC];
}

@end
