//
//  WineServerOperations.h
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinePrefix.h"

@interface StartWineServerOperation : NSOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@end


@interface StopWineServerOperation : NSOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix;

@property (readonly) WinePrefix *prefix;

@end


@interface RunOperation : NSOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix program:(NSString *)program arguments:(NSArray *)arguments;

@property (readonly) WinePrefix *prefix;
@property (readonly) NSString *program;
@property (readonly) NSArray *arguments;

@end