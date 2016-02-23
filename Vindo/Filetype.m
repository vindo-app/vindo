//
//  Filetype.m
//  Vindo
//
//  Created by Theodore Dubois on 1/29/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "Filetype.h"
#import "World.h"
#import "World+StartMenu.h"
#import "StartMenuController.h"
#import "StartMenuItem.h"

@implementation Filetype

- (id)initWithFiletypeId:(NSString *)filetypeId inWorld:(World *)world {
    if (self = [super init]) {
        _world = world;
        _filetypeId = filetypeId;
        
        NSURL *plistFile = [[world.filetypesFolder URLByAppendingPathComponent:filetypeId]
                            URLByAppendingPathExtension:@"plist"];
        
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfURL:plistFile];
        _progId = plist[@"ProgID"];
        _command = plist[@"Command"];
        _executable = plist[@"Exectable"];
        _extensions = [self undotExtensions:plist[@"Extensions"]];
        _docName = plist[@"Name"];
        _appName = plist[@"AppName"];
        
        _docIconURL = [[world.filetypesFolder URLByAppendingPathComponent:filetypeId] URLByAppendingPathExtension:@"file.icns"];
        _docIcon = [[NSImage alloc] initByReferencingURL:_docIconURL];
        _appIconURL = [[world.filetypesFolder URLByAppendingPathComponent:filetypeId] URLByAppendingPathExtension:@"app.icns"];
        _appIcon = [[NSImage alloc] initByReferencingURL:_appIconURL];
        
        if (![self findAnAppBundle]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)findAnAppBundle {
    NSLog(@"%@: finding an app bundle", self.filetypeId);
    StartMenu *menu = [StartMenuController sharedInstance].menu;
    NSAssert(menu.world == self.world, @"something bad happened");
    
    for (StartMenuItem *item in menu.items) {
        if ([self.appName isEqualToString:item.name]) {
            _bundle = item.bundle;
            NSLog(@"%@: found an app bundle (%@)", self.filetypeId, _bundle);
            [_bundle addFiletype:self];
            return YES;
        }
    }
    return NO;
}

- (NSArray *)undotExtensions:(NSArray *)extensions {
    NSMutableArray *undotted = [NSMutableArray new];
    for (NSString *extension in extensions) {
        NSAssert([extension hasPrefix:@"."], @"extension %@ should begin with .", extension);
        [undotted addObject:[extension substringFromIndex:1]];
    }
    return undotted.copy;
}

@end
