//
//  ImageResizingValueTransformer.m
//  Vindo
//
//  Created by Theodore Dubois on 12/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ImageResizingValueTransformer.h"

@implementation ImageResizingValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (NSImage *)transformedValue:(NSImage *)image {
    image = [image copy];
    image.size = NSMakeSize(48, 48);
    return image;
}

@end
