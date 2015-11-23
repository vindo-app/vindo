//
//  UpdatePreferencesViewController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/23/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "UpdatePreferencesViewController.h"

@interface UpdatePreferencesViewController ()

@end

@implementation UpdatePreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)setUpdateInterval:(id)sender {
    if ([[sender selectedItem] tag] < 86400) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"You're crazy!"
                                         defaultButton:@"I've Been Warned"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"That's going to devour your bandwidth."];
        alert.alertStyle = NSCriticalAlertStyle;
        
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
}

- (NSString *)identifier {
    return [self className];
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:@"SoftwareUpdate"];
}

- (NSString *)toolbarItemLabel {
    return @"Updates";
}

@end
