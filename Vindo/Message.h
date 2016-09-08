//
//  Message.h
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (readonly) NSString *text;
@property (readonly) NSDate *timestamp;
@property (readonly) BOOL fromUser;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithText:(NSString *)text;

@end
