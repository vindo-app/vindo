//
//  NSUserDefaults+KeyPaths.h
//  Vindo
//
//  Created by Theodore Dubois on 1/28/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (KeyPaths)

- (id)valueForKeyPathArray:(NSArray *)keyPathArray;
- (void)setValue:(id)value forKeyPathArray:(NSArray *)keyPathArray;

@end
