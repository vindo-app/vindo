//
//  IndexSetToIntTransformer.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "IndexSetToIntTransformer.h"

@implementation IndexSetToIntTransformer

+ (Class)transformedValueClass {
    return [NSIndexSet class];
}

- (NSIndexSet *)transformedValue:(NSNumber *)value {
    if (value == nil)
        return [NSIndexSet indexSet];
    return [NSIndexSet indexSetWithIndex:[value unsignedIntegerValue]];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (NSNumber *)reverseTransformedValue:(NSIndexSet *)indexes {
    if (indexes.count == 0)
        return nil;
    return @([indexes firstIndex]);
}

@end
