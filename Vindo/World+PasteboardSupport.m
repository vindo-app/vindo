//
//  World+PasteboardSupport.m
//  
//
//  Created by Dubois, Theodore Alexander on 12/18/15.
//
//

#import "World.h"

@implementation World (PasteboardSupport)

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[WorldPasteboardType];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    return [self.worldId pasteboardPropertyListForType:NSPasteboardTypeString];
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[WorldPasteboardType];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsData;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    return [[World alloc] initWithId:[[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:NSPasteboardTypeString]];
}

@end

NSString *const WorldPasteboardType = @"co.vindo.world";