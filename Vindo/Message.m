//
//  Message.m
//  Vindo
//
//  Created by Theodore Dubois on 9/5/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initFromDictionary:(NSDictionary *)dictionary {
    static NSDateFormatter *dateParser = nil;
    if (dateParser == nil) {
        dateParser = [[NSDateFormatter alloc] init];
        dateParser.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateParser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZ";
        dateParser.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    
    if (self = [super init]) {
        _text = dictionary[@"body"];
        _fromUser = [dictionary[@"from_user"] boolValue];
        _timestamp = [dateParser dateFromString:dictionary[@"created_at"]];
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    if (self = [super init]) {
        _text = text;
        _fromUser = YES;
        _timestamp = [NSDate date];
    }
    return self;
}

@end
