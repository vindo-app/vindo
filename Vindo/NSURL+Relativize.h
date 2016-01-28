//
//  NSURL+Relativize.h
//  Vindo
//
//  Created by Theodore Dubois on 1/28/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Relativize)

- (NSString *)pathRelativeToURL:(NSURL *)dir;

@end
