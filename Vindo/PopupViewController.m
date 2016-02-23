//
//  Popup.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "PopupViewController.h"
#import "FirstTimeSetupController.h"
#import "SetupViewController.h"
#import "StartMenuViewController.h"
#import "NoProgramsViewController.h"
#import "StartMenuController.h"

@interface PopupViewController ()

@property BOOL firstTimeSetupHappening;

@property StartMenuViewController *defaultViewController;
@property SetupViewController *setupViewController;
@property NoProgramsViewController *noProgramsViewController;

@property (nonatomic) NSViewController *importantViewController;
@property IBOutlet NSView *placeholderView;
@property IBOutlet NSPopUpButton *actionButton;

@property (weak) IBOutlet NSMenu *popupMenu;
@property (weak) IBOutlet NSMenu *worldsMenu;

@end

@implementation PopupViewController

- (instancetype)init {
    return [super initWithNibName:@"Popup" bundle:nil];
}

- (void)awakeFromNib {
    self.defaultViewController = [StartMenuViewController new];
    self.setupViewController = [SetupViewController new];
    self.noProgramsViewController = [NoProgramsViewController new];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(makeNoProgramsImportant:)
                   name:@"MakeNoProgramsImportant"
                 object:nil];
    [center addObserver:self
               selector:@selector(makeDefaultImportant:)
                   name:@"MakeDefaultImportant"
                 object:nil];
    
    [self findMathConstants];
    
    if ([FirstTimeSetupController sharedInstance].happening) {
        self.importantViewController = self.setupViewController;
    } else if ([StartMenuController sharedInstance].menu.items.count == 0){
        self.importantViewController = self.noProgramsViewController;
    } else {
        self.importantViewController = self.defaultViewController;
    }
    
    [center addObserver:self
               selector:@selector(firstTimeSetupStarted:)
                   name:FirstTimeSetupDidStartNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(firstTimeSetupEnded:)
                   name:FirstTimeSetupDidCompleteNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(menuItemWasClicked:)
                   name:NSMenuDidSendActionNotification
                 object:self.popupMenu];
    [center addObserver:self
               selector:@selector(menuItemWasClicked:)
                   name:NSMenuDidSendActionNotification
                 object:self.worldsMenu];
}

- (void)firstTimeSetupStarted:(NSNotification *)notification {
    self.importantViewController = self.setupViewController;
}

- (void)firstTimeSetupEnded:(NSNotification *)notification {
    self.importantViewController = self.defaultViewController;
}

- (void)menuItemWasClicked:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EliminatePopup" object:self];
}

- (void)makeNoProgramsImportant:(NSNotification *)notification {
    [self performSelector:@selector(setImportantViewController:) withObject:self.noProgramsViewController afterDelay:0];
}

- (void)makeDefaultImportant:(NSNotification *)notification {
    self.importantViewController = self.defaultViewController;
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSViewFrameDidChangeNotification
                                                  object:oldView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(importantViewResized:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:importantViewController.view];
}

- (void)importantViewResized:(NSNotification *)notification {
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
    [self.view setFrameSize:self.importantViewController.view.frame.size];
    
    NSRect actionFrame;
    actionFrame.size = self.actionButton.frame.size;
    actionFrame.origin.y = actionY;
    actionFrame.origin.x = self.view.frame.size.width - actionRightPadding;
    self.actionButton.frame = actionFrame;
    
    [self.importantViewController.view setFrameOrigin:NSMakePoint(0, bottomPadding)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReshowPopup" object:self];
}

@end
