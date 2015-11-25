//
//  Popup.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/17/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "PopupViewController.h"

@interface PopupViewController ()

@property IBOutlet NSView *importantView;
@property (strong) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSPopUpButton *actionButton;

@end

@implementation PopupViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"Popup" bundle:nil]) {
        
    }
    return self;
}

- (void)makeImportant:(NSView *)view {
    CGFloat bottomPadding = self.importantView.frame.origin.y;
    
    [self.view replaceSubview:self.importantView with:view];
    self.importantView = view;
    
    NSRect importantRect;
    importantRect.size = self.importantView.frame.size;
    importantRect.origin.x = 0;
    importantRect.origin.y = bottomPadding;
    self.importantView.frame = importantRect;
    
    NSSize popupSize;
    popupSize.width = self.importantView.frame.size.width;
    popupSize.height = self.importantView.frame.size.height + bottomPadding;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetPopupSize" object:self userInfo:@{@"size": [NSValue valueWithSize:popupSize]}];
}
- (IBAction)button:(id)sender {
    [self makeImportant:self.imageView];
}

@end
