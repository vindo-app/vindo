//
//  main.m
//  Vindo
//
//  Created by Theodore Dubois on 2/27/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    // I have to put it here because it has to happen before the main nib is loaded
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
                                 @"worlds": @[@"Default World"],
                                 @"defaultWorldIndex": @0
                                 }];
    
    return NSApplicationMain(argc, argv);
}
