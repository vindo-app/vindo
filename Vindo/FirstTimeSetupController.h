//
//  FirstTimeSetupController.h
//  Vindo
//
//  Created by Theodore Dubois on 9/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FirstTimeSetupController : NSObject

@property (readonly, getter=isHappening) BOOL happening;

+ (FirstTimeSetupController *)sharedInstance;

@end

extern NSString *const FirstTimeSetupDidStartNotification;
extern NSString *const FirstTimeSetupDidCompleteNotification;