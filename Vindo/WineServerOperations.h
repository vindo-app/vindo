//
//  WineServerOperations.h
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"

@interface StartWineServerOperation : NSOperation

- (instancetype)initWithWorld:(World *)prefix;

@property (readonly) World *world;

@end


@interface StopWineServerOperation : NSOperation

- (instancetype)initWithWorld:(World *)prefix;

@property (readonly) World *world;

@end


@interface RunOperation : NSOperation

- (instancetype)initWithWorld:(World *)prefix program:(NSString *)program arguments:(NSArray *)arguments;

@property (readonly) World *world;
@property (readonly) NSString *program;
@property (readonly) NSArray *arguments;

@end