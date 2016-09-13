//
//  MessagesWindowController.h
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "MessagesController.h"

@interface MessagesWindowController : NSWindowController <WebUIDelegate>

@property MessagesController *messagesController;

@end
