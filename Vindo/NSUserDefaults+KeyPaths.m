//
//  NSUserDefaults+KeyPaths.m
//  Vindo
//
//  Created by Theodore Dubois on 1/10/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "NSUserDefaults+KeyPaths.h"

@implementation NSUserDefaults (KeyPaths)

- (id)valueForKeyPathArray:(NSArray *)keyPathArray {
    id node = self;
    for (NSString *key in keyPathArray) {
        if (![node respondsToSelector:@selector(objectForKey:)])
            return nil;
        node = [node objectForKey:key];
    }
    return node;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    [self setValue:value forKeyPathArray:[keyPath componentsSeparatedByString:@"."]];
}

- (void)setValue:(id)object forKeyPathArray:(NSArray *)keys {
    if (keys.count == 1) {
        [self setObject:object forKey:keys[0]];
        return;
    }
    
    id top = [[self objectForKey:keys[0]] mutableCopy];
    if (top == nil) {
        top = [NSMutableDictionary new];
    } else if (![top respondsToSelector:@selector(objectForKey:)]) {
        [NSException raise:NSGenericException format:@"something's wrong, tell someone"];
    }
    
    id node = top;
    for (int i = 1; i < keys.count - 1; i++) {
        if ([node objectForKey:keys[i]] == nil) {
            [node setObject:[NSMutableDictionary new] forKey:keys[i]];
        } else if (![[node objectForKey:keys[i]] respondsToSelector:@selector(objectForKey:)]) {
            [NSException raise:NSGenericException format:@"something's wrong, tell someone"];
        } else {
            [node setObject:[[node objectForKey:keys[i]] mutableCopy] forKey:keys[i]];
        }
        
        node = [node objectForKey:keys[i]];
    }
    
    [node setObject:object forKey:keys.lastObject];
    [self setObject:top forKey:keys[0]];
}

@end
