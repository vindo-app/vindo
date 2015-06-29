//
//  LaunchController.h
//  Vindo
//
//  Created by Theodore Dubois on 6/26/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchController : NSObject

- (void)run:(NSString *)program;
- (void)run:(NSString *)program withArguments:(NSArray *)arguments;

- (void)launch:(NSURL *)url;


@end
