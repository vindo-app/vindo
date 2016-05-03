//
//  AppBundle.m
//  Vindo
//
//  Created by Theodore Dubois on 1/2/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "AppBundle.h"
#import "StartMenuItem.h"
#import "Filetype.h"

static NSFileManager *fm;
static NSURL *appBundleFolder;
static NSURL *windowsProgramBundle;

@implementation AppBundle

- (instancetype)initWithStartMenuItem:(StartMenuItem *)item {
    if (self = [super init]) {
        self.item = item;
        _filetypes = @[];
    }
    return self;
}

- (void)generate {
    // decide whether it should be parenthesized or not
    NSURL *noParensURL = [[appBundleFolder URLByAppendingPathComponent:self.item.itemPath] URLByAppendingPathExtension:@"app"];
    NSURL *parensURL = [[appBundleFolder URLByAppendingPathComponent:
                   [NSString stringWithFormat:@"%@ (%@)", self.item.itemPath, self.item.world.name]]
                  URLByAppendingPathExtension:@"app"];
    BOOL noParensExistsButWrongWorld = [fm fileExistsAtPath:noParensURL.path];
    if (noParensExistsButWrongWorld) {
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfURL:[noParensURL URLByAppendingPathComponent:@"Contents/Info.plist"]];
        noParensExistsButWrongWorld = noParensExistsButWrongWorld && ![info[@"World"] isEqualToString:self.item.world.name];
    }
    if ([fm fileExistsAtPath:parensURL.path] || noParensExistsButWrongWorld) {
        _bundleURL = parensURL;
        _parenthesized = YES;
    } else {
        _bundleURL = noParensURL;
        _parenthesized = NO;
    }
    
    if (self.exists)
        return;
    
    NSError *error;
    
    if (![fm createDirectoryAtURL:_bundleURL.URLByDeletingLastPathComponent
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error]) {
        [NSApp presentError:error];
        NSLog(@"%@", error);
    }
    
    if (![fm copyItemAtURL:windowsProgramBundle
                     toURL:self.bundleURL
                     error:&error]) {
        [NSApp presentError:error];
        NSLog(@"%@", error);
    }
    
    // copy the icon(s)
    if (![fm copyItemAtURL:self.item.iconURL
                     toURL:[self.bundleURL URLByAppendingPathComponent:@"Contents/Resources/PrettyPixels.icns"]
                     error:&error]) {
        [NSApp presentError:error];
        NSLog(@"%@", error);
    }
    if (self.filetypes) {
        for (Filetype *filetype in self.filetypes) {
            if (![fm copyItemAtURL:filetype.docIconURL
                             toURL:[[[self.bundleURL URLByAppendingPathComponent:@"Contents/Resources"]
                                     URLByAppendingPathComponent:filetype.filetypeId]
                                    URLByAppendingPathExtension:@"icns"]
                             error:&error]) {
                [NSApp presentError:error];
                NSLog(@"%@", error);
            }
        }
    }
    
    // figure out the plist
    NSURL *infoPlistURL = [self.bundleURL URLByAppendingPathComponent:@"Contents/Info.plist"];
    
    NSMutableDictionary *infoPlist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:infoPlistURL]
                                                                               options:NSPropertyListMutableContainers
                                                                                format:NULL error:&error];
    if (!infoPlist) {
        [NSApp presentError:error];
        NSLog(@"%@", error);
    }
    
    // It's fine to cast kCF* from CFString because of toll free bridging.
    [infoPlist setValue:self.item.name
                 forKey:(NSString *)kCFBundleNameKey];
    [infoPlist setValue:[NSString stringWithFormat:@"co.vindo.windows-program.%@", self.item.itemPath]
                 forKey:(NSString *)kCFBundleIdentifierKey];
    
    [infoPlist setValue:self.item.itemPath forKey:@"ItemPath"];
    [infoPlist setValue:self.item.world.name forKey:@"World"];
    
    if (self.filetypes.count != 0) {
        NSMutableArray *documentTypes = [NSMutableArray new];
        for (Filetype *filetype in self.filetypes) {
            NSDictionary *documentType = @{
                                           @"CFBundleTypeExtensions": filetype.extensions,
                                           @"CFBundleTypeIconFile": filetype.filetypeId,
                                           @"CFBundleTypeName": filetype.docName,
                                           @"CFBundleTypeRole": @"Editor",
                                           @"Command": filetype.command,
                                           };
            [documentTypes addObject:documentType];
        }
        [infoPlist setValue:documentTypes forKey:@"CFBundleDocumentTypes"];
    }
    
    
    NSData *infoPlistData = [NSPropertyListSerialization dataWithPropertyList:infoPlist
                                                                       format:NSPropertyListXMLFormat_v1_0
                                                                      options:0
                                                                        error:&error];
    if (!infoPlistData) {
        [NSApp presentError:error];
        NSLog(@"%@", error);
    }
    
    if (![infoPlistData writeToURL:infoPlistURL atomically:YES]) {
        NSLog(@"Stuff failed!");
        NSAssert(NO, @"Could not write info plist");
        return;
    }
}

- (void)remove {
    if (!self.exists)
        return;
    
    NSError *error;
    
    if (![fm removeItemAtURL:self.bundleURL
                       error:&error]) {
        [NSApp presentError:error];
        return;
    }
}

- (void)start {
    [self generate];
    [[NSWorkspace sharedWorkspace] launchApplicationAtURL:self.bundleURL
                                                  options:NSWorkspaceLaunchDefault
                                            configuration:@{}
                                                    error:nil];
}

- (BOOL)exists {
    if (self.bundleURL == nil)
        return NO;
    if (![fm fileExistsAtPath:self.bundleURL.path])
        return NO;
    
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfURL:[self.bundleURL URLByAppendingPathComponent:@"Contents/Info.plist"]];
    if (info == nil)
        return NO;
    
    if ([info[@"World"] isEqualToString:self.item.world.name]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addFiletype:(Filetype *)filetype {
    // avoid duplicates
    for (Filetype *ft in self.filetypes)
        if ([ft.filetypeId isEqualToString:filetype.filetypeId])
            return;
    
    _filetypes = [self.filetypes arrayByAddingObject:filetype];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(regen) object:nil];
    [self performSelector:@selector(regen) withObject:nil afterDelay:0];
}

- (void)regen {
    [self remove];
    [self generate];
}

+ (void)initialize {
    fm = [NSFileManager defaultManager];
#ifdef DEBUG
    appBundleFolder = [[fm URLsForDirectory:NSApplicationDirectory
                                 inDomains:NSUserDomainMask][0]
                       URLByAppendingPathComponent:@"Vindo"];
#else
    appBundleFolder = [fm URLsForDirectory:NSApplicationDirectory
                                 inDomains:NSUserDomainMask][0];
#endif
    windowsProgramBundle = [[NSBundle mainBundle] URLForResource:@"Windows Program"
                                                   withExtension:@"app"];
}

@end
