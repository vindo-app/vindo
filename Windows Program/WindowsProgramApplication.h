//
//  WindowsProgramApplication.h
//  Vindo
//
//  Created by Theodore Dubois on 1/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Just what we need from it.
@interface WineApplicationController : NSObject <NSApplicationDelegate>

- (BOOL)handleEvent:(NSEvent *)anEvent;
- (void)didSendEvent:(NSEvent *)anEvent;

@end

@interface WindowsProgramApplication : NSApplication {
    WineApplicationController *wineController;
}

// We need this.
@property (readwrite, assign, nonatomic) WineApplicationController *wineController;

@end
