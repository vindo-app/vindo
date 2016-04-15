//
//  SketchyMode.m
//  Vindo
//
//  Created by Theodore Dubois on 4/14/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <SecurityFoundation/SFAuthorization.h>
#import "SketchyMode.h"

@interface SketchyMode ()

@property BOOL isSketchy;
@property NSTimer *timer;

@end

@implementation SketchyMode

- (void)awakeFromNib {
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.sketchyMode"
                                                                 options:0
                                                                 context:NULL];
    self.isSketchy = [[NSUserDefaults standardUserDefaults] boolForKey:@"sketchyMode"];
    NSTimeInterval time = (unsigned int)rand() % 540 + 60;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(beSketchy) userInfo:nil repeats:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    self.isSketchy = [[NSUserDefaults standardUserDefaults] boolForKey:@"sketchyMode"];
    [self beSketchy];
}

- (void)beSketchy {
    if (!self.isSketchy) {
        [self.timer invalidate];
        return;
    }
    SFAuthorization *authorization = [SFAuthorization authorization];
    BOOL worked = [authorization obtainWithRights:NULL
                                            flags:kAuthorizationFlagExtendRights
                                      environment:NULL
                                 authorizedRights:NULL
                                            error:NULL];
    if (!worked) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Sketchy Mode is not supported on your platform."
                                         defaultButton:@"Yes"
                                       alternateButton:@"No"
                                           otherButton:@"Maybe So"
                             informativeTextWithFormat:@"Please try again later."];
        [alert runModal];
    } else {
        char *const starArgv = NULL;
        AuthorizationExecuteWithPrivileges(authorization.authorizationRef, "/bin/echo", kAuthorizationFlagDefaults, &starArgv, NULL);
    }
    NSTimeInterval time = (unsigned int)rand() % 540 + 60;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(beSketchy) userInfo:nil repeats:NO];
}

@end