//
//  StartMenuItem.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartMenuItem : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *path;
@property (readonly) NSString *args;

- (instancetype)initFromFile:(NSURL *)file;

@end
