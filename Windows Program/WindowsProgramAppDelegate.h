//
//  AppDelegate.h
//  Windows Program
//
//  Created by Dubois, Theodore Alexander on 12/18/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../AppBundleCommunicationThing.h"

@interface WindowsProgramAppDelegate : NSObject <NSApplicationDelegate> {
    NSDistantObject <AppBundleCommunicationThing> *communicationThing;
    NSURL *usr;
    NSString *world;
    NSString *file;
}

@end

