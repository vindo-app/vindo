//
//  Parsing.m
//  Vindo
//
//  Created by Theodore Dubois on 2/24/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *scanToken(NSScanner *scanner);

NSString *programFromCommand(NSString *command) {
    return scanToken([NSScanner scannerWithString:command]);
}

NSArray *argumentsFromCommand(NSString *command) {
    NSScanner *scanner = [NSScanner scannerWithString:command];
    scanner.charactersToBeSkipped = [NSCharacterSet new];
    NSMutableArray *args = [NSMutableArray new];
    scanToken(scanner);
    while (!scanner.atEnd) {
        NSString *arg = scanToken(scanner);
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
        if (arg != nil)
            [args addObject:arg];
    }
    return args;
}

NSArray *splitArguments(NSString *arguments) {
    NSScanner *scanner = [NSScanner scannerWithString:arguments];
    scanner.charactersToBeSkipped = [NSCharacterSet new];
    NSMutableArray *args = [NSMutableArray new];
    while (!scanner.atEnd) {
        NSString *arg = scanToken(scanner);
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
        if (arg != nil)
            [args addObject:arg];
    }
    return args;
}

static NSString *scanToken(NSScanner *scanner) {
    NSCharacterSet *quoted = [[NSCharacterSet characterSetWithCharactersInString:@"\""] invertedSet];
    NSCharacterSet *nonquoted = [[NSCharacterSet characterSetWithCharactersInString:@" \""] invertedSet];
    NSString *token;
    if ([scanner.string characterAtIndex:scanner.scanLocation] == '"') {
        [scanner scanString:@"\"" intoString:nil];
        [scanner scanCharactersFromSet:quoted intoString:&token];
        [scanner scanString:@"\"" intoString:nil];
    } else {
        [scanner scanCharactersFromSet:nonquoted intoString:&token];
    }
    return token;
}

NSString *windowsPathFromUnixPath(NSString *unix) {
    return [NSString stringWithFormat:@"Z:\\%@", [unix stringByReplacingOccurrencesOfString:@"/" withString:@"\\"]];
}