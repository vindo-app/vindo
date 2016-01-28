//
//  NSURL+Relativize.m
//  Vindo
//
//  Created by Theodore Dubois on 1/28/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "NSURL+Relativize.h"

@implementation NSURL (Relativize)

// http://stackoverflow.com/questions/23258962/nsurl-display-relative-urls

- (NSString *)pathRelativeToURL:(NSURL *)from {
    NSURL *to = self;
    
    NSString * toString = [[to absoluteString] stringByStandardizingPath];
    NSMutableArray * toPieces = [NSMutableArray arrayWithArray:[toString pathComponents]];
    
    NSString * fromString = [[from absoluteString] stringByStandardizingPath];
    NSMutableArray * fromPieces = [NSMutableArray arrayWithArray:[fromString pathComponents]];
    
    NSMutableString * relPath = [NSMutableString string];
    
    NSString * toTrimmed = toString;
    NSString * toPiece = NULL;
    NSString * fromTrimmed = fromString;
    NSString * fromPiece = NULL;
    
    NSMutableArray * parents = [NSMutableArray array];
    NSMutableArray * pieces = [NSMutableArray array];
    
    if(toPieces.count >= fromPieces.count) {
        NSUInteger toCount = toPieces.count;
        while(toCount > fromPieces.count) {
            toPiece = [toTrimmed lastPathComponent];
            toTrimmed = [toTrimmed stringByDeletingLastPathComponent];
            [pieces insertObject:toPiece atIndex:0];
            toCount--;
        }
        
        while(![fromTrimmed isEqualToString:toTrimmed]) {
            toPiece = [toTrimmed lastPathComponent];
            toTrimmed = [toTrimmed stringByDeletingLastPathComponent];
            fromPiece = [fromTrimmed lastPathComponent];
            fromTrimmed = [fromTrimmed stringByDeletingLastPathComponent];
            if(![toPiece isEqualToString:fromPiece]) {
                [parents addObject:@".."];
                [pieces insertObject:toPiece atIndex:0];
            }
        }
        
    } else {
        NSUInteger fromCount = fromPieces.count;
        
        while(fromCount > toPieces.count) {
            fromPiece = [fromTrimmed lastPathComponent];
            fromTrimmed = [fromTrimmed stringByDeletingLastPathComponent];
            [parents addObject:@".."];
            fromCount--;
        }
        
        while(![toTrimmed isEqualToString:fromTrimmed]) {
            toPiece = [toTrimmed lastPathComponent];
            toTrimmed = [toTrimmed stringByDeletingLastPathComponent];
            fromPiece = [fromTrimmed lastPathComponent];
            fromTrimmed = [fromTrimmed stringByDeletingLastPathComponent];
            [parents addObject:@".."];
            [pieces insertObject:toPiece atIndex:0];
        }
        
    }
    
    [relPath appendString:[parents componentsJoinedByString:@"/"]];
    if(parents.count > 0) [relPath appendString:@"/"];
    [relPath appendString:[pieces componentsJoinedByString:@"/"]];
    
    NSLog(@"%@",relPath);
    
    return [NSURL URLWithString:relPath].path;
}

@end
