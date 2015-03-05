//
//  WineServer.h
//  Vindo
//
//  Created by Theodore Dubois on 3/4/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WineServer : NSObject

+ (WineServer *)defaultServer;

- (void)runExe:(NSString *)exePath;

- (void)makeDefaultServer;

@end
