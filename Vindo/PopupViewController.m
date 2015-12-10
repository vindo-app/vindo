//
//  Popup.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "PopupViewController.h"
#import "FirstTimeSetupController.h"

@interface PopupViewController ()

@property BOOL firstTimeSetupHappening;

@property IBOutlet NSView *defaultView;
@property (weak) IBOutlet NSPopUpButton *actionButton;
@property IBOutlet NSView *setupView;

@property NSView *importantView;

@property (weak) IBOutlet NSProgressIndicator *spinningThing;

@end

@implementation PopupViewController

- (instancetype)init {
    return [super initWithNibName:@"Popup" bundle:nil];
}

- (void)awakeFromNib {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if ([FirstTimeSetupController sharedInstance].happening) {
        [self firstTimeSetupStarted:nil];
    }
    [center addObserver:self
               selector:@selector(firstTimeSetupStarted:)
                   name:FirstTimeSetupDidStartNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(firstTimeSetupEnded:)
                   name:FirstTimeSetupDidCompleteNotification
                 object:nil];
    
    self.importantView = self.defaultView;
    
    [self.spinningThing startAnimation:self];
}

- (void)firstTimeSetupStarted:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(makeImportant:)
                           withObject:self.setupView
                        waitUntilDone:NO];
}

- (void)firstTimeSetupEnded:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(makeImportant:)
                           withObject:self.defaultView
                        waitUntilDone:NO];
}

- (void)makeImportant:(NSView *)view {
    if (view == nil)
        return;
    CGFloat bottomPadding = self.importantView.frame.origin.y;
    CGFloat actionY = self.actionButton.frame.origin.y;
    CGFloat actionRightPadding = self.view.frame.size.width - self.actionButton.frame.origin.x;
    
    NSSize popupSize;
    popupSize.width = view.frame.size.width;
    popupSize.height = view.frame.size.height + bottomPadding;
    NSRect popupFrame = self.view.frame;
    popupFrame.size = popupSize;
    self.view.frame = popupFrame;
    
    [self.view replaceSubview:self.importantView with:view];
    self.importantView = view;

    NSRect actionFrame;
    actionFrame.size = self.actionButton.frame.size;
    actionFrame.origin.y = actionY;
    actionFrame.origin.x = self.view.frame.size.width - actionRightPadding;
    self.actionButton.frame = actionFrame;

    NSRect importantRect;
    importantRect.size = self.importantView.frame.size;
    importantRect.origin.x = 0;
    importantRect.origin.y = bottomPadding;
    self.importantView.frame = importantRect;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReshowPopup" object:self];
}

@end
