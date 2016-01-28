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
- (NSString *)programForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)world;
- (NSString *)argumentsForStartMenuItem:(NSString *)itemPath inWorld:(NSString *)world;

@end
