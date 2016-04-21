//
//  AppBundleCommunicationThing.h
//  Vindo
//
//  Created by Theodore Dubois on 1/6/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONNECTION_NAME @"co.vindo.app-bundle-communication"

@protocol AppBundleCommunicationThing <NSObject>

- (bycopy NSURL *)usrURL;
- (BOOL)activateWorldNamed:(NSString *)world;
- (bycopy NSDictionary *)environmentForWorld:(NSString *)world;
- (NSString *)logFilePathForWorld:(NSString *)worldName;

- (NSString *)programForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)world;
- (NSArray *)argumentsForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)world;

- (void)openFile:(NSString *)file withFiletype:(NSString *)filetype inWorld:(NSString *)world;
- (NSString *)programForFile:(NSString *)file withFiletype:(NSString *)filetype inWorld:(NSString *)world;
- (NSArray *)argumentsForFile:(NSString *)file withFiletype:(NSString *)filetype inWorld:(NSString *)world;

@end
