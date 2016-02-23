//
//  FiletypeDatabase.m
//  Vindo
//
//  Created by Theodore Dubois on 1/29/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import <CDEvents/CDEvents.h>
#import "FiletypeDatabase.h"
#import "NSURL+Relativize.h"
#import "World+StartMenu.h"
#import "Filetype.h"

@interface FiletypeDatabase ()

@property NSMutableArray *mutableFiletypes;

@property NSURL *filetypesFolder;
@property World *world;
@property CDEvents *events;

@end

@implementation FiletypeDatabase

- (id)initWithWorld:(World *)world {
    if (self = [super init]) {
        self.world = world;
        
        self.filetypesFolder = world.filetypesFolder;
        [[NSFileManager defaultManager] createDirectoryAtURL:self.filetypesFolder
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
        
        self.mutableFiletypes = [NSMutableArray new];
        [self initializeFiletypes];
        
        self.events = [[CDEvents alloc] initWithURLs:@[self.filetypesFolder]
                                            delegate:self
                                           onRunLoop:[NSRunLoop mainRunLoop]
                                sinceEventIdentifier:kCDEventsSinceEventNow
                                notificationLantency:1
                             ignoreEventsFromSubDirs:NO
                                         excludeURLs:@[]
                                 streamCreationFlags:kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes];
    }
    
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event {
    if (![event.URL.path hasSuffix:@".plist"])
        return;
    
    NSString *filetypeId = [event.URL pathRelativeToURL:self.filetypesFolder].stringByDeletingPathExtension;
    [self addFiletypeWithId:filetypeId];
}

- (void)initializeFiletypes {
    for (NSString *filetype in [[NSFileManager defaultManager] enumeratorAtPath:self.filetypesFolder.path]) {
        [self addFiletypeWithId:filetype.stringByDeletingPathExtension];
    }
}

- (void)addFiletypeWithId:(NSString *)id {
    Filetype *filetype = [[Filetype alloc] initWithFiletypeId:id inWorld:self.world];
    if (filetype)
        [self.mutableFiletypes addObject:filetype];
}

- (NSArray *)filetypes {
    return self.mutableFiletypes.copy;
}

@end
