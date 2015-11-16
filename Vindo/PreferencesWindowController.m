//
//  PreferencesWindowController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/13/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (instancetype)init {
    if (self = [super initWithWindowNibName:@"Preferences"]) {
        // Nothing yet.
    }
    return self;
}

- (IBAction)setUpdateInterval:(id)sender {
    if ([[sender selectedItem] tag] < 86400) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"You're crazy!"
                                         defaultButton:@"I've Been Warned"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"That's going to devour your bandwidth."];
        alert.alertStyle = NSCriticalAlertStyle;
        
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
    }
}

@end
