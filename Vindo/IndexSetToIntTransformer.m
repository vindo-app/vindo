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
    return [NSIndexSet indexSetWithIndex:[value unsignedIntegerValue]];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (NSNumber *)reverseTransformedValue:(NSIndexSet *)indexes {
    return @([indexes firstIndex]);
}

@end
