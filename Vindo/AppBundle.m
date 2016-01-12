//
//  AppBundle.m
//  Vindo
//
//  Created by Theodore Dubois on 1/2/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "AppBundle.h"
#import "StartMenuItem.h"

static NSFileManager *fm;
static NSURL *appBundleFolder;
static NSURL *windowsProgramBundle;

@implementation AppBundle

- (instancetype)initWithStartMenuItem:(StartMenuItem *)item {
    if (self = [super init]) {
        self.item = item;
    }
    return self;
}

- (void)generate {
    if (self.exists)
        return;
    
    NSError *error;
        
    if (![fm createDirectoryAtURL:appBundleFolder
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error]) {
        [NSApp presentError:error];
        return;
    }
    
    if (![fm copyItemAtURL:windowsProgramBundle
                     toURL:self.bundleURL
                     error:&error]) {
        [NSApp presentError:error];
        return;
    }
    
    // copy the icon
    if (![fm copyItemAtURL:self.item.iconURL
                     toURL:[self.bundleURL URLByAppendingPathComponent:@"Contents/Resources/PrettyPixels.icns"]
                     error:&error]) {
        [NSApp presentError:error];
        return;
    }
    
    // figure out the plist
    NSURL *infoPlistURL = [self.bundleURL URLByAppendingPathComponent:@"Contents/Info.plist"];
    
    NSMutableDictionary *infoPlist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:infoPlistURL]
                                                                               options:NSPropertyListMutableContainers
                                                                                format:NULL error:&error];
    if (!infoPlist) {
        [NSApp presentError:error];
        return;
    }
    
    // It's fine to cast kCF* from CFString because of toll free bridging.
    [infoPlist setValue:self.item.name forKey:(NSString *)kCFBundleNameKey];
    [infoPlist setValue:[NSString stringWithFormat:@"co.vindo.windows-program.%@", self.item.nativeIdentifier]
                 forKey:(NSString *)kCFBundleIdentifierKey];
    
    [infoPlist setValue:self.item.nativeIdentifier forKey:@"NativeIdentifier"];
    [infoPlist setValue:self.item.world.name forKey:@"World"];
    
    NSData *infoPlistData = [NSPropertyListSerialization dataWithPropertyList:infoPlist
                                                                       format:NSPropertyListXMLFormat_v1_0
                                                                      options:0
                                                                        error:&error];
    if (!infoPlistData) {
        [NSApp presentError:error];
        return;
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
    return [fm fileExistsAtPath:self.bundleURL.path];
}

- (NSURL *)bundleURL {
    return [[appBundleFolder URLByAppendingPathComponent:_item.name] URLByAppendingPathExtension:@"app"];
}

+ (void)initialize {
    fm = [NSFileManager defaultManager];
    appBundleFolder = [[fm URLsForDirectory:NSApplicationDirectory
                                  inDomains:NSUserDomainMask][0]
                            URLByAppendingPathComponent:@"Vindo"];
    
    
    windowsProgramBundle = [[NSBundle mainBundle] URLForResource:@"Windows Program"
                                                   withExtension:@"app"];
}

@end
