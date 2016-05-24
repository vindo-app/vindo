//
//  Parsing.m
//  Vindo
//
//  Created by Theodore Dubois on 2/24/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import "NSURL+Relativize.h"

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

NSString *windowsPathFromUnixPath(NSString *unix, World *world) {
    NSURL *url = [NSURL fileURLWithPath:unix];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSURL *driveLink in [fm contentsOfDirectoryAtURL:[world.url URLByAppendingPathComponent:@"dosdevices"]
         includingPropertiesForKeys:nil options:0 error:nil]) {
        NSString *destination = [fm destinationOfSymbolicLinkAtPath:driveLink.path error:nil];
        NSURL *drive;
        if ([destination characterAtIndex:0] == '/')
            drive = [NSURL fileURLWithPath:destination];
        else
            drive = [NSURL fileURLWithPath:[[driveLink.URLByDeletingLastPathComponent.path stringByAppendingString:@"/"]
                                            stringByAppendingString:destination].stringByStandardizingPath];
        if (!drive)
            continue;
        NSURLRelationship relationship;
        if (![fm getRelationship:&relationship ofDirectoryAtURL:drive toItemAtURL:url error:nil])
            continue;
        if (relationship != NSURLRelationshipOther) {
            NSString *pathOnDrive = [[url pathRelativeToURL:drive] stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
            NSString *driveLetter = driveLink.lastPathComponent.uppercaseString;
            return [NSString stringWithFormat:@"%@\\%@", driveLetter, pathOnDrive];
        }
    }
    // this can't happen because there's a Z drive that matches any path that fails all other drives
    NSCAssert(NO, @"BAD STUFFZ HAPPAND");
    return nil;
}

NSString *unixPathFromWindowsPath(NSString *windows, World *world) {
    return [[[world.url.path stringByAppendingPathComponent:@"dosdevices"]
             stringByAppendingPathComponent:[windows stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]]
            stringByResolvingSymlinksInPath];
}