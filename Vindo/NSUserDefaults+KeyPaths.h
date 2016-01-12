//
//  NSUserDefaults+KeyPaths.h
//  Vindo
//
//  Created by Theodore Dubois on 1/10/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (KeyPaths)

- (id)objectForKeyPath:(NSString *)keyPath;
- (void)setObject:(id)object forKeyPath:(NSString *)keyPath;

@end
