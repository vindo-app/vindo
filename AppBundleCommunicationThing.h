//
//  AppBundleCommunicationThing.h
//  Vindo
//
//  Created by Theodore Dubois on 1/6/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONNECTION_NAME @"com.tbodt.Vindo.app-bundle-communication"

typedef NS_ENUM(NSInteger, WorldStatus) {
    WorldStatusNonexistent,
    WorldStatusStarting,
    WorldStatusRunning,
};

@protocol AppBundleCommunicationThing <NSObject>

- (bycopy NSURL *)usrURL;
- (WorldStatus)statusOfWorldNamed:(NSString *)world;
- (bycopy NSDictionary *)environmentForWorld:(NSString *)world;
- (NSString *)commandLineForStartMenuItem:(NSString *)nativeIdentifier inWorld:(NSString *)world;

@end
