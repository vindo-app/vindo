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

@property IBOutlet NSViewController *defaultViewController;
@property IBOutlet NSViewController *setupViewController;

@property (nonatomic) NSViewController *importantViewController;
@property IBOutlet NSView *placeholderView;
@property IBOutlet NSPopUpButton *actionButton;

@end

@implementation PopupViewController

- (instancetype)init {
    return [super initWithNibName:@"Popup" bundle:nil];
}

- (void)viewDidLoad {
    [self findMathConstants];
    
    if ([FirstTimeSetupController sharedInstance].happening) {
        self.importantViewController = self.setupViewController;
    } else {
        self.importantViewController = self.defaultViewController;
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(firstTimeSetupStarted:)
                   name:FirstTimeSetupDidStartNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(firstTimeSetupEnded:)
                   name:FirstTimeSetupDidCompleteNotification
                 object:nil];
}

- (void)firstTimeSetupStarted:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(setImportantViewController:)
                           withObject:self.setupViewController
                        waitUntilDone:NO];
}

- (void)firstTimeSetupEnded:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(setImportantViewController:)
                           withObject:self.defaultViewController
                        waitUntilDone:NO];
}

- (void)setImportantViewController:(NSViewController *)importantViewController {
    NSView *oldView;
    if (!_importantViewController)
        oldView = self.placeholderView;
    else
        oldView = _importantViewController.view;
    [self.view replaceSubview:oldView with:importantViewController.view];
    _importantViewController = importantViewController;
    [self doTheMath];
}

static CGFloat bottomPadding;
static CGFloat actionY;
static CGFloat actionRightPadding;

- (void)findMathConstants {
    bottomPadding = self.placeholderView.frame.origin.y;
    actionY = self.actionButton.frame.origin.y;
    actionRightPadding = self.view.frame.size.width - self.actionButton.frame.origin.x;
}

- (void)doTheMath {
    NSSize popupSize;
    popupSize.width = self.importantViewController.view.frame.size.width;
    popupSize.height = self.importantViewController.view.frame.size.height + bottomPadding;
    NSRect popupFrame = self.view.frame;
    popupFrame.size = popupSize;
    self.view.frame = popupFrame;

    NSRect actionFrame;
    actionFrame.size = self.actionButton.frame.size;
    actionFrame.origin.y = actionY;
    actionFrame.origin.x = self.view.frame.size.width - actionRightPadding;
    self.actionButton.frame = actionFrame;

    NSRect importantRect;
    importantRect.size = self.importantViewController.view.frame.size;
    importantRect.origin.x = 0;
    importantRect.origin.y = bottomPadding;
    self.importantViewController.view.frame = importantRect;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReshowPopup" object:self];
}

@end
