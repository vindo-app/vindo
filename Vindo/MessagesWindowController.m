//
//  MessagesWindowController.m
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "MessagesWindowController.h"
#import "MessageCommunicator.h"

@interface MessagesWindowController ()

@property (weak) IBOutlet NSTextField *messageBox;

@property IBOutlet WebView *messages;

@end

@implementation MessagesWindowController

- (instancetype)init {
    if (self = [super initWithWindowNibName:@"MessagesWindowController"]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self
                   selector:@selector(reactivateMessageBox:)
                       name:MessageSentNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(displayMessage:)
                       name:MessageRecievedNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(displayMessage:)
                       name:MessageSentNotification
                     object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    self.messages.drawsBackground = NO;
    [self installStylesheet];
    self.messages.postsFrameChangedNotifications = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messagesResized:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:self.messages];
}

- (IBAction)sendMessage:(id)sender {
    if (self.messageBox.stringValue.length == 0)
        return;
    Message *message = [[Message alloc] initWithText:self.messageBox.stringValue];
    self.messageBox.enabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMessageNotification object:self userInfo:@{@"message":message}];
}

- (void)displayMessage:(NSNotification *)n {
    Message *message = n.userInfo[@"message"];
    
    [self performSelectorOnMainThread:@selector(addMessageToWebkit:) withObject:message waitUntilDone:NO];
}

- (void)addMessageToWebkit:(Message *)message {
    DOMDocument *document = self.messages.mainFrame.DOMDocument;
    DOMElement *p = [document createElement:@"p"];
    DOMHTMLElement *span = (DOMHTMLElement *) [document createElement:@"span"];
    span.innerText = message.text;
    if (message.fromUser)
        [p setAttribute:@"class" value:@"from-user"];
    else
        [p setAttribute:@"class" value:@"to-user"];
    [p appendChild:span];
    [document.body appendChild:p];
    [self.messages performSelector:@selector(scrollToEndOfDocument:) withObject:nil afterDelay:0.1];
}

static NSString *messagesCSS =
@"html {"
@"    font-family: -apple-system, -apple-system-body;"
@"    font-size: 13px;"
@"}"
@"body {"
@"    margin-left: 0;"
@"    margin-right: 0;"
@"}"

@"p span {"
@"    display: inline-block;"
@"    max-width: 60%;"
@"    padding: 0.25rem 0.75rem;"
@"    border-radius: 1rem;"
@"    margin-bottom: 0.5rem;"
@"    clear: both;"
@"    word-wrap: break-word;"
@"}"

@".from-user span {"
@"    float: right;"
@"    background-color: white;"
@"    color: black;"
@"}"

@".to-user span {"
@"    float: left;"
@"    background-color: #c62828;"
@"    color: white;"
@"}"
;

- (void)installStylesheet {
    DOMDocument *document = self.messages.mainFrame.DOMDocument;
    DOMHTMLStyleElement *styleElement = (DOMHTMLStyleElement *) [document createElement:@"style"];
    styleElement.innerText = messagesCSS;
    DOMHTMLElement *head = (DOMHTMLElement *) [[document getElementsByTagName:@"head"] item:0];
    [head appendChild:styleElement];
}

- (void)messagesResized:(NSNotification *)n {
    [self.messages scrollToEndOfDocument:nil];
}

- (void)reactivateMessageBox:(NSNotification *)n {
    self.messageBox.stringValue = @"";
    self.messageBox.enabled = YES;
    [self.window makeFirstResponder:self.messageBox];
}

@end
