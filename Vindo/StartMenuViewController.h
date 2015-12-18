//
//  StartMenuViewController.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 12/14/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StartMenuViewController : NSViewController

@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;

- (void)setRows:(NSUInteger)rows columns:(NSUInteger)columns;

@end
