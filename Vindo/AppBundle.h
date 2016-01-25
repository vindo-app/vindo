//
//  AppBundle.h
//  Vindo
//
//  Created by Theodore Dubois on 1/2/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StartMenuItem;

@interface AppBundle : NSObject

- (instancetype)initWithStartMenuItem:(StartMenuItem *)item;

@property (readonly) BOOL exists;
- (void)generate;
- (void)remove;
- (void)start;

@property (readonly) NSURL *bundleURL;
@property (readonly, getter=isParenthesized) BOOL parenthesized;

@property (weak) StartMenuItem *item;

@end
